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
# File: mem_debug06.sh
#
# Description: Default information of lowmem killer debug display test
#
# Authors:     Wangyuting - wangyuting36@huawei.com
#
# History:     Mar 20 2022 - init scripts
#
################################################################################
source tst_oh.sh

do_setup()
{
    zcat /proc/config.gz | grep CONFIG_LOWMEM=y || tst_res TCONF "CONFIG_LOWMEM=y & CONFIG_LMKD_DBG=y not satisfied!"
    zcat /proc/config.gz | grep CONFIG_LMKD_DBG=y || tst_res TCONF "CONFIG_LOWMEM=y & CONFIG_LMKD_DBG=y not satisfied!"
}

do_test()
{
    local lmkd_oom_score_adj=$(cat /proc/lmkd_dbg_trigger | awk 'BEGIN{FS=":"} $1=="lmkd_oom_score_adj"{print $2}')
    local lmkd_no_cma_cnt=$(cat /proc/lmkd_dbg_trigger | awk 'BEGIN{FS=":"} $1=="lmkd_no_cma_cnt"{print $2}')

    if [ $lmkd_oom_score_adj -ne 0 ] && [ $lmkd_no_cma_cnt -ne 0 ]; then
        tst_res TFAIL "Default information of lowmem killer debug display test failed!"
    else
        tst_res TPASS "Default information of lowmem killer debug display test pass."
    fi
}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit