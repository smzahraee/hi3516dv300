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
# File: mem_debug08.sh
#
# Description:  Ashmem information display test
#
# Authors:     Wangyuting - wangyuting36@huawei.com
#
# History:     Mar 23 2022 - init scripts
#
################################################################################
source tst_oh.sh

do_setup()
{

}

do_test()
{
    local pid=$(ps -ef | grep "com.ohos.launch" | grep -v grep | awk '{print $2}')
    local ashmem_info_lines=$(cat /proc/$pid/smaps | grep ashmem | wc -l)

    if [ $ashmem_info_lines -le 0 ]; then
        tst_res TFAIL "Ashmem information display test failed!"
    else
        tst_res TPASS "Ashmem information display test pass."
    fi
}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit