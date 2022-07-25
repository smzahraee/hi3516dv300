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
}

do_test()
{
    ls /sys/kernel/debug/tracing/events/rtg/ | grep find_rtg_cpu &&
    ls /sys/kernel/debug/tracing/events/rtg/ | grep sched_rtg_task_each &&
    ls /sys/kernel/debug/tracing/events/rtg/ | grep sched_rtg_valid_normalized_util
    if [ $? -eq 0 ]; then
        tst_res TPASS "trace nodes are existed"
    else
        tst_res TFAIL "trace nodes are not existed"
    fi
}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit