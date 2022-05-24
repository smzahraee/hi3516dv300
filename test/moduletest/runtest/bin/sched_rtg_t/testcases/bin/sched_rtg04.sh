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
# File: sched_rtg04.sh
#
# Description: sched RTG tracing test
#
# Authors:     liudanning - liudanning@h-partners.com
#
# History:     April 6 2022 - init scripts
#
################################################################################

source tst_oh.sh

do_setup()
{
    frame_value=$(cat /sys/kernel/debug/tracing/events/rtg/rtg_frame_sched/enable)
    task_value=$(cat /sys/kernel/debug/tracing/events/rtg/sched_rtg_task_each/enable)
    cpu_value=$(cat /sys/kernel/debug/tracing/events/rtg/find_rtg_cpu/enable)
    normalized_value=$(cat /sys/kernel/debug/tracing/events/rtg/sched_rtg_valid_normalized_util/enable)

    aa start -b ohos.samples.ecg -a ohos.samples.ecg.default
    sleep 1
    PID=$(ps -ef | grep ohos.samples.ecg | grep -v grep | awk '{print $2}')
    echo 1 > /sys/kernel/debug/tracing/events/rtg/rtg_frame_sched/enable
    echo 1 > /sys/kernel/debug/tracing/events/rtg/sched_rtg_task_each/enable
    echo 1 > /sys/kernel/debug/tracing/events/rtg/find_rtg_cpu/enable
    echo 1 > /sys/kernel/debug/tracing/events/rtg/sched_rtg_valid_normalized_util/enable
}

do_test()
{
    local res=0
    local sched_group_id=/proc/$PID/sched_group_id

    tst_res TINFO "Start sched RTG trace catching test ..."
    bytrace -t 10 -b 32000 --overwrite sched ace app disk ohos graphic sync workq ability > rtgtrace.ftrace &
    tst_res TINFO "Checking sched RTG trace ..."
    sleep 3
    for i in $(seq 1 50);do
        echo 0 > $sched_group_id
        echo 2 > $sched_group_id
    done
    sleep 50
    cat rtgtrace.ftrace | grep "sched_rtg_task_each" &&
    cat rtgtrace.ftrace | grep "find_rtg_cpu" &&
    cat rtgtrace.ftrace | grep "sched_rtg_valid_normalized_util"
    if [ $? -eq 0 ]; then
        tst_res TPASS "trace info found."
        rm -rf rtgtrace.ftrace
    else
        tst_res TFAIL "trace info no found!"
    fi
}

do_clean()
{
    echo $frame_value > /sys/kernel/debug/tracing/events/rtg/rtg_frame_sched/enable &&
    echo $task_value > /sys/kernel/debug/tracing/events/rtg/sched_rtg_task_each/enable &&
    echo $cpu_value > /sys/kernel/debug/tracing/events/rtg/find_rtg_cpu/enable &&
    echo $normalized_value > /sys/kernel/debug/tracing/events/rtg/sched_rtg_valid_normalized_util/enable
    aa force-stop ohos.samples.ecg
}

do_setup
do_test
do_clean
tst_exit