#!/bin/sh
################################################################################
#
# Copyright (C) 2022 Huawei Device Co., Ltd.
# SPDX-License-Identifier: GPL-2.0
#
# Legacy blkg rwstat helpers enabled by CONFIG_BLK_CGROUP_RWSTAT.
# Do not use in new code.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
# File: cpuisolation05.sh
#
# Description: check CPU lightweight isolation trace test
#
# Authors:     liudanning - liudanning@h-partners.com
#
# History:     Mar 24 2022 - init scripts
#
################################################################################

source tst_oh.sh

do_setup()
{
    tracing_on=$(cat /sys/kernel/debug/tracing/tracing_on)
    eval_need=$(cat /sys/kernel/debug/tracing/events/sched/core_ctl_eval_need/enable)
    set_busy=$(cat /sys/kernel/debug/tracing/events/sched/core_ctl_set_busy/enable)
    update_nr_need=$(cat /sys/kernel/debug/tracing/events/sched/core_ctl_update_nr_need/enable)
}

do_test()
{
    tst_res TINFO "Start to check CPU lightweight isolation trace test."
    echo 1 > /sys/kernel/debug/tracing/tracing_on
    echo 1 > /sys/kernel/debug/tracing/events/sched/core_ctl_eval_need/enable
    echo 1 > /sys/kernel/debug/tracing/events/sched/core_ctl_set_busy/enable
    echo 1 > /sys/kernel/debug/tracing/events/sched/core_ctl_update_nr_need/enable

    tst_res TINFO "Start CPU trace catching test ..."
    bytrace -t 10 -b 32000 --overwrite sched ace app disk ohos graphic sync  \
    workq ability > cputrace.ftrace &
    sleep 5
    for i in $(seq 1 8);do
        sh create_process.sh 40
        sleep 2
        ps -ef | grep "create_process" | grep -v "grep" | cut -c 9-18 | xargs kill -9
    done &
    for i in $(seq 1 100);do
    echo 1 /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
    echo $((RANDOM %4 + 1)) /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
    done&
    sleep 40

    tst_res TINFO "Checking CPU trace ..."
    cat cputrace.ftrace | grep "set_busy" &&
    cat cputrace.ftrace | grep "update_nr_need"
    if [ $? -eq 0 ]; then
        tst_res TPASS "trace info found."
        rm -rf cputrace.ftrace
    else
        tst_res TFAIL "trace info no found!"
    fi
}

do_clean()
{
    echo $tracing_on > /sys/kernel/debug/tracing/tracing_on
    echo $eval_need > /sys/kernel/debug/tracing/events/sched/core_ctl_eval_need/enable
    echo $set_busy > /sys/kernel/debug/tracing/events/sched/core_ctl_set_busy/enable
    echo $update_nr_need > /sys/kernel/debug/tracing/events/sched/core_ctl_update_nr_need/enable
    echo 4 /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
    echo 1 /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
    ps -ef | grep "create_process" | grep -v "grep" | cut -c 9-18 | xargs kill -9
    rm -rf taskpid.txt
}

do_setup
do_test
do_clean
tst_exit