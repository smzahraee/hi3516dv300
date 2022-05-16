#!/bin/sh
################################################################################
#
# Copyright (C) 2022 Huawei Device Co., Ltd.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
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
    aa start -b ohos.samples.ecg -a ohos.samples.ecg.default
    sleep 1
    PID=`ps -ef | grep ohos.samples.ecg | grep -v grep | awk '{print $2}'`
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

    local _rtg_id=$(cat /proc/sched_rtg_debug | grep RTG_ID | grep -v grep | awk '{print $3}')
    local _rtg_pid=$(cat /proc/sched_rtg_debug | grep ohos.samples.ec | grep -v grep | awk '{print $3}')
    if [ $_set_rtgid -ne 0 ]; then
        if [ $_rtg_id -eq $_expect_rtgid ]; then
            tst_res TPASS "RTG_ID $_rtg_id equal to expected value."
            if [ $_rtg_pid -eq $PID ]; then
                tst_res TPASS "process $_pid rtgid set to $rtg_pid expected."
            else
                tst_res TFAIL "$rtg_pid not equal to expected value!"
            fi
        else
            tst_res TFAIL "RTG_ID $_rtg_id not equal to expected value!"
        fi
    else
        cat $_sched_rtg_debug | grep "RTG tasklist empty"
        if [ $? -eq 0 ]; then
            tst_res TPASS "process $_pid rtgid set to $_set_rtgid expected."
        else
            tst_res TFAIL "process $_pid rtgid set to $_set_rtgid unexpected!"
        fi
    fi
}

do_clean()
{
    aa force-stop ohos.samples.ecg
}

do_setup
do_test
do_clean
tst_exit