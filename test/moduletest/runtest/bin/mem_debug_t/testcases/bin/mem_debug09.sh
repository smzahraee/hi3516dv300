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
# File: mem_dubug09.sh
#
# Description: /sys/module/reclaim_acct/parameters/disable interface test
#              0: valid disable
#              nonzero: reserved
#
# Authors:     Wang Yuting - wangyuting36@huawei.com
#
# History:     May 26 2022 - init scripts
#
################################################################################

source tst_oh.sh

do_setup()
{
    zcat /proc/config.gz | grep CONFIG_RECLAIM_ACCT=y || tst_res TCONF "CONFIG_RECLAIM_ACCT=y not satisfied!"
    reclaim_acct_disable="/sys/module/reclaim_acct/parameters/disable"
    reclaim_acct_disable_def=$(cat /sys/module/reclaim_acct/parameters/disable)
}

do_test()
{
    set_check_disable 0 0
    set_check_disable -1 -1
}

set_check_disable()
{
    local _set_disable=$1
    local _expect_disable=$2

    echo $_set_disable > $reclaim_acct_disable
    if [ $? -eq 0 ]; then
        tst_res TPASS "Interface disable set to $_set_disable expected."
    else
        tst_res TFAIL "Interface disable set to $_set_disable unexpected!"
    fi

    local _cur_disable=$(cat $reclaim_acct_disable)
    if [ $_cur_disable -eq $_expect_disable ]; then
        tst_res TPASS "Interface disable $_cur_disable equal to expected value."
    else
        tst_res TFAIL "Interface disable $_cur_disable unexpected value $_expect_disable!"
    fi
}

do_clean()
{
    echo $reclaim_acct_disable_def > $reclaim_acct_disable
}

do_setup
do_test
do_clean
tst_exit