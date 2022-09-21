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
# File: mem_dubug10.sh
#
# Description: /proc/lmkd_dbg_trigger interface test
#              -1000-1000: valid lmkd_adj
#              others: not reserved error
#
# Authors:     Wang Yuting - wangyuting36@huawei.com
#
# History:     May 26 2022 - init scripts
#
################################################################################

source tst_oh.sh

do_setup()
{
    zcat /proc/config.gz | grep CONFIG_LOWMEM=y || tst_res TCONF "CONFIG_LOWMEM=y not satisfied!"
    zcat /proc/config.gz | grep CONFIG_LMKD_DBG=y || tst_res TCONF "CONFIG_LMKD_DBG=y not satisfied!"
    lmkd_dbg_trigger="/proc/lmkd_dbg_trigger"
    lmkd_oom_score_adj_def=$(cat /proc/lmkd_dbg_trigger | awk 'BEGIN{FS=":"} $1=="lmkd_oom_score_adj"{print $2}')
}

do_test()
{
    set_check_lmkd_oom_score_adj -1001 1 $lmkd_oom_score_adj_def
    set_check_lmkd_oom_score_adj -1000 0 -1000
    set_check_lmkd_oom_score_adj 1 0 1
    set_check_lmkd_oom_score_adj 1000 0 1000
    set_check_lmkd_oom_score_adj 1001 1 1000
}

set_check_lmkd_oom_score_adj()
{
    local _set_lmkd_adj=$1
    local _expect_ret=$2
    local _expect_lmkd_adj=$3

    echo $_set_lmkd_adj > $lmkd_dbg_trigger
    if [ $? -eq $_expect_ret ]; then
        tst_res TPASS "Interface lmkd_adj set to $_set_lmkd_adj expected."
    else
        tst_res TFAIL "Interface lmkd_adj set to $_set_lmkd_adj unexpected!"
    fi

    local _cur_lmkd_adj=$(cat $lmkd_dbg_trigger | awk 'BEGIN{FS=":"} $1=="lmkd_oom_score_adj"{print $2}')
    if [ $_cur_lmkd_adj -eq $_expect_lmkd_adj ]; then
        tst_res TPASS "Interface lmkd_adj $_cur_lmkd_adj equal to expected value."
    else
        tst_res TFAIL "Interface lmkd_adj $_cur_lmkd_adj unexpected value $_expect_lmkd_adj!"
    fi
}

do_clean()
{
    echo $lmkd_oom_score_adj_def > $lmkd_dbg_trigger
}

do_setup
do_test
do_clean
tst_exit