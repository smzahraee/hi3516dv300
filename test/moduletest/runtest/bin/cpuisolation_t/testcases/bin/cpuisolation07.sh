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
# File: cpuisolation07.sh
#
# Description: check enable node status about CPU isolation
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
    enable=${dir_name}/enable
    pre_enable=$(cat $enable)

    cat $enable
    if [ $? -eq 0 ]; then
        tst_res TPASS "Node enable can be read."
    else
        tst_res TFAIL "Node enable status error."
        ret=$(( $ret + 1 ))
    fi

    echo 1 > $enable
    if [ $? -eq 0 ]; then
        tst_res TPASS "Node enable can be opened."
    else
        tst_res TFAIL "Node enable open error."
        ret=$(( $ret + 1 ))
    fi

    echo 0 > $enable
    if [ $? -eq 0 ]; then
        tst_res TPASS "Node enable can be closed."
    else
        tst_res TFAIL "Node enable close error."
        ret=$(( $ret + 1 ))
    fi

    echo 2 > $enable
    if [ $(cat $enable) -eq 1 ]; then
        tst_res TPASS "Node enable writing 2 is abnormal."
    else
        tst_res TFAIL "Node enable writing 2 is normal."
        ret=$(( $ret + 1 ))
    fi

    echo -1 > $enable
    if [ $(cat $enable) -eq 1 ]; then
        tst_res TPASS "Node enable writing -1 is abnormal."
    else
        tst_res TFAIL "Node enable writing -1 is normal."
        ret=$(( $ret + 1 ))
    fi

    echo ret=$ret
    if [ $ret -eq 0 ]; then
        tst_res TPASS "enable node status is right."
    else
        tst_res TFAIL "enable node status is wrong!"
    fi
}

do_clean()
{
    echo $pre_enable > $enable
}

do_setup
do_test
do_clean
tst_exit