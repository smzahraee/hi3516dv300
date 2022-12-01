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
        return False, f'"{make}" errors --> \n {errmsg}'

    return True, f'"{make}" success!'


def make_config(arch, config, corss_compile, knl_path):
    make = f"make {config} ARCH={arch} CROSS_COMPILE={corss_compile}"
    outmsg, errmsg, ret = exec_cmd(make, cwd=knl_path)
    if ret:
        print(f'"{make}" errors --> \n {errmsg}')
        return False, f'"{make}" errors --> \n {errmsg}'

    return True, f'"{make}" success!'


def make_j(arch, cross_compile, knl_path):
    make = f'make -j{os.cpu_count()} ARCH={arch} CROSS_COMPILE={cross_compile}'
    outmsg, errmsg, ret = exec_cmd(make, cwd=knl_path)
    if ret:
        print(f'"{make}" errors --> \n {errmsg}')
        return False, f'"{make}" errors --> \n {errmsg}'
    elif len(errmsg) > 0:
        print(f'"{make}" warnings --> \n {errmsg}')
        return False, f'"{make}" warnings --> \n {errmsg}'

    return True, f'"{make}" success!'


def cp_config(arch, config, config_path, knl_path):
    if os.path.exists(config_path.format(arch, config)):
        cp = f'cp ' + config_path.format(arch, config) + ' ' + os.path.join(knl_path, 'arch', arch, 'configs', config)
        outmsg, errmsg, ret = exec_cmd(cp)
        if ret:
            print(f'"{cp}" errors --> \n {errmsg}')
            return False, f'"{cp}" errors --> \n {errmsg}'
    else:
        print(f'"{config_path.format(arch, config)}" not exists!')
        return False, f'"{config_path.format(arch, config)}" not exists!'

    return True, f'"{cp}" success!'


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
    if not ret:
        logger.error(msg)

    ret, msg = make_cmd('make oldconfig', arch, cross_compile, knl_path)
    if not ret:
        logger.error(msg)

    ret, msg = make_cmd('make clean', arch, cross_compile, knl_path)
    if not ret:
        logger.error(msg)

    ret, msg = make_j(arch, cross_compile, knl_path)
    if not ret:
        logger.error(msg)

    ret, msg = cp_config(arch, config, config_path, knl_path)
    if not ret:
        logger.error(msg)
    else:
        ret, msg = make_config(arch, config, cross_compile, knl_path)
        if not ret:
            logger.error(msg)

        ret, msg = make_cmd('make clean', arch, cross_compile, knl_path)
        if not ret:
            logger.error(msg)

        ret, msg = make_j(arch, cross_compile, knl_path)
        if not ret:
            logger.error(msg)

    ret, msg = make_cmd('make allmodconfig', arch, cross_compile, knl_path)
    if not ret:
        logger.error(msg)

    sed = f'sed -i s/^.*CONFIG_FRAME_WARN.*$/CONFIG_FRAME_WARN=2048/ .config'
    outmsg, errmsg, ret = exec_cmd(sed, cwd=knl_path)

    ret, msg = make_cmd('make clean', arch, cross_compile, knl_path)
    if not ret:
        logger.error(msg)

    ret, msg = make_j(arch, cross_compile, knl_path)
    if not ret:
        logger.error(msg)

    return True, f'build success!'


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
    build(arch, config, config_path, cross_compile, knl_path, logger)

    arch = 'arm64'
    config = 'rk3568_standard_defconfig'
    cross_compile = '../../../prebuilts/gcc/linux-x86/aarch64/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin/aarch64-linux-gnu-'
    build(arch, config, config_path, cross_compile, knl_path, logger)


if __name__ == "__main__":
    main()
