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
# File: cpuisolation08.sh
#
# Description: check global_state node status about CPU isolation
#
# Authors:     liudanning - liudanning@h-partners.com
#
# History:     Mar 24 2022 - init scripts
#
################################################################################


source tst_oh.sh

do_setup()
{
    
}

do_test()
{
    local ret=0
    dir_name=/sys/devices/system/cpu/cpu0/core_ctl
    global_state=${dir_name}/global_state

    cat $global_state
    if [ $? -eq 0 ]; then
        tst_res TPASS "Node global_state can be read."
    else
        tst_res TFAIL "Node global_state status error."
        ret=$(( $ret + 1 ))
    fi

    echo 1 > $global_state
    if [ $? -ne 0 ]; then
        tst_res TPASS "Node global_state can be write."
    else
        tst_res TFAIL "Node global_state status error."
        ret=$(( $ret + 1 ))
    fi
    echo ret=$ret
    if [ $ret -eq 0 ]; then
        tst_res TPASS "global_state node status is right."
    else
        tst_res TFAIL "global_state node status is wrong!"
    fi
}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit