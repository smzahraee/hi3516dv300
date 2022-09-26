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
# File: mem_debug07.sh
#
# Description: Information of lowmem killer debug display test
#
# Authors:     Wangyuting - wangyuting36@huawei.com
#
# History:     Mar 23 2022 - init scripts
#
################################################################################
source tst_oh.sh

do_setup()
{
    zcat /proc/config.gz | grep CONFIG_LOWMEM=y || tst_res TCONF "CONFIG_LOWMEM=y not satisfied!"
    zcat /proc/config.gz | grep CONFIG_LMKD_DBG=y || tst_res TCONF "CONFIG_LMKD_DBG=y not satisfied!"
}

do_test()
{
    local ret=0

    lmkd_oom_score_adj_def=$(cat /proc/lmkd_dbg_trigger | awk 'BEGIN{FS=":"} $1=="lmkd_oom_score_adj"{print $2}')
    echo 1 > /proc/lmkd_dbg_trigger

    local lmkd_oom_score_adj=$(cat /proc/lmkd_dbg_trigger | awk 'BEGIN{FS=":"} $1=="lmkd_oom_score_adj"{print $2}')

    if [ $lmkd_oom_score_adj -ne 1 ]; then
        tst_res TFAIL "lmkd_ dbg_ Trigger doesn't set successfully"
        ret=$(($ret + 1))
    fi

    local dmesg_lowmem_info=$(dmesg | grep "lowmem" | grep pid | grep uid | grep tgid | grep total_vm  \
    | grep rss | grep nptes | grep swap | grep adj | grep s | grep name)

    if [ "$dmesg_lowmem_info" == "" ]; then
        tst_res TFAIL "The information of lowmem in dmesg is displayed incorrectly"
        ret=$(($ret + 1))
    fi

    if [ $ret -eq 0 ]; then
        tst_res TPASS "Information of lowmem killer debug display test pass."
    else
        tst_res TFAIL "Information of lowmem killer debug display test failed!"
    fi
}

do_clean()
{
    echo $lmkd_oom_score_adj_def > /proc/lmkd_dbg_trigger
}

do_setup
do_test
do_clean
tst_exit