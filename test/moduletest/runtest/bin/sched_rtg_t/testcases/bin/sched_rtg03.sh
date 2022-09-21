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
# File: sched_rtg03.sh
#
# Description: sched RTG /proc/sched_rtg_debug interface test
#
# Authors:     liudanning - liudanning@h-partners.com
#
# History:     April 6 2022 - init scripts
#
################################################################################

source tst_oh.sh

do_setup()
{
    sh create_process.sh 1
    sleep 1
    PID=$(ps -ef | grep "create_process" | grep -v grep | awk '{print $2}')
}

do_test()
{
    local res=0
    local sched_group_id=/proc/$PID/sched_group_id

    tst_res TINFO "Start sched RTG /proc/sched_rtg_debug interface test ..."
    cur_rtgid=$(cat $sched_group_id)
    tst_res TINFO "process $PID already in rtgid $sched_group_id, remove it firstly..."
    echo 0 > $sched_group_id

    set_check_rtgid_debug 2 $PID 0 2

    set_check_rtgid_debug 0 $PID 0 0
}

set_check_rtgid_debug()
{
    local _set_rtgid=$1
    local _pid=$2
    local _expect_ret=$3
    local _expect_rtgid=$4

    local _sched_group_id=/proc/$_pid/sched_group_id
    local _sched_rtg_debug=/proc/sched_rtg_debug

    echo $_set_rtgid > $_sched_group_id
    if [ $? -eq $_expect_ret ]; then
        tst_res TPASS "process $_pid rtgid set to $_set_rtgid expected."
        if [ $(cat /proc/$_pid/sched_group_id) -eq $_expect_rtgid ]; then
            tst_res TPASS "process $_pid rtgid equal to expected value."
        else
            tst_res TFAIL "process $_pid rtgid not equal to expected value!"
        fi
    else
        tst_res TFAIL "process $_pid rtgid set to $_set_rtgid unexpected!"
    fi

    local _rtg_id=$(cat /proc/sched_rtg_debug | grep RTG_ID | grep -v grep | awk '{print $3}' | head -n 1)
    local _rtg_pid=$(cat /proc/sched_rtg_debug | grep $PID | grep -v grep | awk '{print $3}')
    if [ $_set_rtgid -ne 0 ]; then
        if [ $_rtg_id -eq $_expect_rtgid ]; then
            tst_res TPASS "RTG_ID $_rtg_id exists in $_sched_rtg_debug expected."
            if [ $_rtg_pid -eq $PID ]; then
                tst_res TPASS "PID $_pid exists in $_sched_rtg_debug expected."
            else
                tst_res TFAIL "PID $_pid not exists in $_sched_rtg_debug unexpected!"
            fi
        else
            tst_res TFAIL "RTG_ID $_rtg_id not exists in $_sched_rtg_debug unexpected!"
        fi
    else
        cat $_sched_rtg_debug | grep $PID
        if [ $? -ne 0 ]; then
            tst_res TPASS "process $_pid rtgid set to 0 expected."
        else
            tst_res TFAIL "process $_pid rtgid set to 0 unexpected!"
        fi
    fi
}

do_clean()
{
    ps -ef | grep "create_process" | grep -v "grep" | cut -c 9-18  \
    | xargs kill -9
}

do_setup
do_test
do_clean
tst_exit