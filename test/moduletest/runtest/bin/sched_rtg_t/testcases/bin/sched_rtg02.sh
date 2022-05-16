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
# File: sched_rtg02.sh
#
# Description: sched RTG /proc/$PID/sched_group_id interface test
#              1: reserved
#              2-20: valid rtgid
#
# Authors:     Ma Feng - mafeng.ma@huawei.com
#
# History:     April 6 2022 - init scripts
#
################################################################################

source tst_oh.sh

do_setup()
{
    aa start -b ohos.samples.ecg -a ohos.samples.ecg.default
    sleep 1
    PID=$(ps -ef | grep ohos.samples.ecg | grep -v grep | awk '{print $2}')
}

do_test()
{
    local res=0
    local sched_group_id=/proc/$PID/sched_group_id

    tst_res TINFO "Start process $PID sched RTG interface test ..."
    cur_rtgid=$(cat $sched_group_id)
    tst_res TINFO "process $PID already in rtgid $sched_group_id, remove it firstly..."
    echo 0 > $sched_group_id

    set_check_rtgid -1 $PID 1 0

    set_check_rtgid 21 $PID 1 0

    set_check_rtgid 1 $PID 1 0

    set_check_rtgid 20 $PID 0 20

    set_check_rtgid 0 $PID 0 0

    set_check_rtgid 2 $PID 0 2

    set_check_rtgid 0 $PID 0 0

    set_check_rtgid 10 $PID 0 10
}

set_check_rtgid()
{
    local _set_rtgid=$1
    local _pid=$2
    local _expect_ret=$3
    local _expect_rtgid=$4

    local _sched_group_id=/proc/$_pid/sched_group_id

    echo $_set_rtgid > $_sched_group_id
    if [ $? -eq $_expect_ret ]; then
        tst_res TPASS "process $_pid rtgid set to $_set_rtgid expected."
    else
        tst_res TFAIL "process $_pid rtgid set to $_set_rtgid unexpected!"
    fi

    local _cur_rtgid=$(cat $_sched_group_id)
    if [ $_cur_rtgid -eq $_expect_rtgid ]; then
        tst_res TPASS "process $_pid rtgid $_cur_rtgid equal to expected value."
    else
        tst_res TFAIL "process $_pid rtgid $_cur_rtgid unexpected value $_expect_rtgid!"
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