#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Copyright (C) 2022 Huawei Device Co., Ltd.
SPDX-License-Identifier: GPL-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
"""

import logging
import os
import re
import select
import sys
import subprocess
import shlex
import time


ignores = [
    "include/trace/events/eas_sched.h: warning: format '%d' expects argument of type 'int', but argument 9 has type 'long unsigned int' [-Wformat=]",
    "drivers/block/zram/zram_drv.c: warning: left shift count >= width of type",
    "include/trace/events/eas_sched.h: note: in expansion of macro",
    "include/trace/events/eas_sched.h: note: format string is defined here",
    "include/trace/trace_events.h: note: in expansion of macro",
    "mm/vmscan.c: warning: suggest parentheses around assignment used as truth value [-Wparentheses]",
    "lib/bitfield_kunit.c: warning: the frame size of \d+ bytes is larger than \d+ bytes",
    "drivers/mmc/host/sdhci-esdhc-imx.c: warning: 'sdhci_esdhc_imx_probe_nondt' defined but not used",
]


class Reporter:
    def __init__(self, arch, path):
        self.arch = arch
        self.path = path


    def normpath(self, filename):
        if re.search("^[\.]+[^/]", filename):
            filename = re.sub("^[\.]+", "", filename)
        return os.path.normpath(filename)


    def format_title(self, title):
        title = re.sub("\u2018", "'", title)
        title = re.sub("\u2019", "'", title)

        return title.strip()


    def report_build_warning(self, filename, regex, details):
        if len(details) == 0 or filename is None:
            return None

        if not os.path.exists(os.path.join(self.path, filename)):
            return None

        line = details[0]
        try:
            warning = re.search(regex, line).group(0)
        except:
            print('Except>>>', details)
            return

        report = {
            'title': self.format_title("%s: %s" % (filename, warning)),
            'filename': filename,
            'report': '\n'.join(details),
            'nr': line.split(':')[1],
        }

        return report


    def parse_build_warning(self, blocks, regex, title_regex):
        issues = {}
        reports = []
        details = []
        filename = None
        unused = False

        for line in blocks:
            attrs = line.split(':')
            if len(attrs) < 5 and filename is None:
                continue
            if line.startswith(' ') or len(attrs) < 2:
                if unused is True:
                    details.append(line)
                continue
            if not regex in line:
                unused = False
                continue
            unused = True
            newfile = self.normpath(attrs[0])
            if newfile != filename:
                if len(details) and filename:
                    if filename in issues:
                        issues[filename].extend(details)
                    else:
                        issues[filename] = details
                filename = newfile
                details = []

            details.append(line)

        if len(details) and filename:
            if filename in issues:
                issues[filename].extend(details)
            else:
                issues[filename] = details

        for filename, details in issues.items():
            report = self.report_build_warning(filename, title_regex, details)
            if not report is None:
                reports.append(report)

        return reports


    def parse(self, content):
        blocks = content.split('\n')
        reports = []

        patterns = (
            ('[-Wunused-but-set-variable]', 'warning: .* set but not used'),
            ('[-Wunused-but-set-parameter]', 'warning: .* set but not used'),
            ('[-Wunused-const-variable=]', 'warning: .* defined but not used'),
            ('[-Wold-style-definition]', 'warning: .* definition'),
            ('[-Wold-style-declaration]', 'warning: .* declaration'),
            ('[-Wmaybe-uninitialized]', 'warning: .* uninitialized'),
            ('[-Wtype-limits]', 'warning: .* always (false|true)'),
            ('[-Wunused-function]', 'warning: .* defined but not used'),
            ('[-Wsequence-point]', 'warning: .* may be undefined'),
            ('[-Wformat=]', 'warning: format.*'),
            ('[-Wunused-variable]', 'warning: [^\[]*'),
            ('[-Wframe-larger-than=]', 'warning: the frame size [^\[]*'),
            ('[-Wshift-count-overflow]', 'warning: left shift count >= width of type'),
            ('definition or declaration', 'warning: .* declared inside parameter list will not be visible outside of this definition or declaration'),
            ('character', 'warning: missing terminating .* character'),
            ('in expansion of macro', 'note: in expansion of macro'),
            ('note: format string is defined here', 'note: format string is defined here'),
            ('[-Wparentheses]', 'suggest parentheses around assignment used as truth value'),
        )

        for regex, title_regex in patterns:
            items = self.parse_build_warning(blocks, regex, title_regex)
            if items is None:
                continue

            reports.extend(items)

        return reports


def exec_cmd(command_list, shell=False, show_output=False, cwd=None):
    if isinstance(command_list, str):
        command_list = shlex.split(command_list)
    elif not isinstance(command_list, list):
        raise f"command_list to exec_cmd need to be a list or string"
    command_list = ['nice'] + [str(s) for s in command_list]

    print(f"cwd: '{cwd}'")
    print(f"cmd: '{command_list}'")
    start = time.time()
    proc = subprocess.Popen(
        command_list if not shell else ' '.join(command_list),
        cwd=cwd,
        shell=shell,
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
        bufsize=1,
        universal_newlines=True,
    )

    outmsg = ""
    errmsg = ""
    poller = select.epoll()
    poller.register(proc.stdout, select.EPOLLIN)
    poller.register(proc.stderr, select.EPOLLIN)
    while proc.poll() is None:
        for fd, event in poller.poll():
            if event is not select.EPOLLIN:
                continue
            if fd == proc.stdout.fileno():
                line = proc.stdout.readline()
                if show_output is True:
                    print(">> [stdout] %s", line.strip('\n'))
                outmsg += line
            elif fd == proc.stderr.fileno():
                line = proc.stderr.readline()
                if show_output is True:
                    print(">> [stderr] %s", line.strip('\n'))
                errmsg += line

    for line in proc.stdout.readlines():
        if show_output is True:
            print(">> [stdout] %s", line.strip('\n'))
        outmsg += line
    for line in proc.stderr.readlines():
        if show_output is True:
            print(">> [stderr] %s", line.strip('\n'))
        errmsg += line

    ret = proc.wait()
    print(f"Returned {ret} in {int(time.time() - start)} seconds")

    return outmsg, errmsg, ret


def make_cmd(cmd, arch, cross_compile, knl_path):
    make = f"{cmd} ARCH={arch} CROSS_COMPILE={cross_compile}"
    outmsg, errmsg, ret = exec_cmd(make, cwd=knl_path)
    if ret:
        print(f'"{make}" errors --> \n {errmsg}')
        return ret, f'"{make}" errors --> \n {errmsg}'

    return ret, f'"{make}" success!'


def make_config(arch, config, corss_compile, knl_path):
    make = f"make {config} ARCH={arch} CROSS_COMPILE={corss_compile}"
    outmsg, errmsg, ret = exec_cmd(make, cwd=knl_path)
    if ret:
        print(f'"{make}" errors --> \n {errmsg}')
        return ret, f'"{make}" errors --> \n {errmsg}'

    return ret, f'"{make}" success!'


def make_j(arch, cross_compile, knl_path):
    make = f'make -j{os.cpu_count()} ARCH={arch} CROSS_COMPILE={cross_compile}'
    outmsg, errmsg, ret = exec_cmd(make, cwd=knl_path)
    if ret:
        print(f'"{make}" errors --> \n {errmsg}')
        return ret, f'"{make}" errors --> \n {errmsg}'
    elif len(errmsg) > 0:
        print(f'"{make}" warnings --> \n {errmsg}')
        result = "success"
        reporter = Reporter(arch, knl_path)
        known_issue = "\nKnown issue:\n"
        for report in reporter.parse(errmsg):
            if ignores and [i for i in ignores if re.match(i, report['title'])]:
                known_issue = known_issue + report['title'] + "\n"
                known_issue = known_issue + report['report'] + "\n"
                continue
            result = 'failed'

        print(known_issue)
        new_issue = "\nNew Issue:\n"
        if result == "failed":
            for report in reporter.parse(errmsg):
                if ignores and [i for i in ignores if re.match(i, report['title'])]:
                    continue
                new_issue = new_issue + report['title'] + "\n"
                new_issue = new_issue + report['report'] + "\n"
            print(new_issue)
            return 2, f'"{make}" warning --> \n {new_issue}'

        return ret, f'"{make}" warnings in ignores --> \n {known_issue}'

    return ret, f'"{make}" success!'


def cp_config(arch, config, config_path, knl_path):
    if os.path.exists(config_path.format(arch, config)):
        cp = f'cp ' + config_path.format(arch, config) + ' ' + os.path.join(knl_path, 'arch', arch, 'configs', config)
        outmsg, errmsg, ret = exec_cmd(cp)
        if ret:
            print(f'"{cp}" errors --> \n {errmsg}')
            return ret, f'"{cp}" errors --> \n {errmsg}'
    else:
        print(f'"{config_path.format(arch, config)}" not exists!')
        return ret, f'"{config_path.format(arch, config)}" not exists!'

    return ret, f'"{cp}" success!'


def get_logger(filename):
    log_format = '%(asctime)s %(name)s %(levelname)s %(message)s'
    log_date_format = '%Y-%m-%d %H:%M:%S'
    logging.basicConfig(
        level=logging.INFO,
        filename=filename,
        format=log_format,
        datefmt=log_date_format
    )
    logger = logging.getLogger(__name__)
    return logger


def build(arch, config, config_path, cross_compile, knl_path, logger):
    ret, msg = make_cmd('make defconfig', arch, cross_compile, knl_path)
    if ret:
        logger.error(msg)
        return ret, msg

    ret, msg = make_cmd('make oldconfig', arch, cross_compile, knl_path)
    if ret:
        logger.error(msg)
        return ret, msg

    ret, msg = make_cmd('make clean', arch, cross_compile, knl_path)
    if ret:
        logger.error(msg)
        return ret, msg

    ret, msg = make_j(arch, cross_compile, knl_path)
    if ret:
        logger.error(msg)
        return ret, msg

    ret, msg = cp_config(arch, config, config_path, knl_path)
    if ret:
        logger.error(msg)
        return ret, msg
    else:
        ret, msg = make_config(arch, config, cross_compile, knl_path)
        if ret:
            logger.error(msg)
            return ret, msg

        ret, msg = make_cmd('make clean', arch, cross_compile, knl_path)
        if ret:
            logger.error(msg)
            return ret, msg

        ret, msg = make_j(arch, cross_compile, knl_path)
        if ret:
            logger.error(msg)
            return ret, msg

    ret, msg = make_cmd('make allmodconfig', arch, cross_compile, knl_path)
    if ret:
        logger.error(msg)
        return ret, msg

    sed = f'sed -i s/^.*CONFIG_FRAME_WARN.*$/CONFIG_FRAME_WARN=2048/ .config'
    outmsg, errmsg, ret = exec_cmd(sed, cwd=knl_path)

    ret, msg = make_cmd('make clean', arch, cross_compile, knl_path)
    if ret:
        logger.error(msg)
        return ret, msg

    ret, msg = make_j(arch, cross_compile, knl_path)
    if ret:
        logger.error(msg)
        return ret, msg

    return 0, f'build success!'


def main():
    config_path = './kernel/linux/config/linux-5.10/arch/{0}/configs/{1}'
    knl_path = './kernel/linux/linux-5.10'
    log_path = os.getcwd()
    now_date = time.strftime("%Y%m%d%H%M%S", time.localtime())
    log_file = os.path.join(log_path, 'kernel_build_test.log')
    logger = get_logger(log_file)

    arch = 'arm'
    config = 'hispark_taurus_standard_defconfig'
    cross_compile = '../../../prebuilts/gcc/linux-x86/arm/gcc-linaro-7.5.0-arm-linux-gnueabi/bin/arm-linux-gnueabi-'
    arm_ret, arm_msg = build(arch, config, config_path, cross_compile, knl_path, logger)

    arch = 'arm64'
    config = 'rk3568_standard_defconfig'
    cross_compile = '../../../prebuilts/gcc/linux-x86/aarch64/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-'
    arm64_ret, arm64_msg = build(arch, config, config_path, cross_compile, knl_path, logger)

    print(f'arm_ret: {arm_ret}, arm64_ret: {arm64_ret}')
    if any([arm_ret, arm64_ret]):
        print('kernel build test failed!')
        exit(arm_ret or arm64_ret)

    print('kernel build test success.')
    exit(0)


if __name__ == "__main__":
    main()
