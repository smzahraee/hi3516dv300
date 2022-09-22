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
# File: enhancedswap02.sh
#
# Description: enhanced swap /dev/memcg/memory.zswapd_single_memcg_param and
#              /dev/memcg/100/memory.zswapd_single_memcg_param interface test
#
# Authors:     Ma Feng - mafeng.ma@huawei.com
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
    local res=0
    local memcg_100_zsmp=/dev/memcg/100/memory.zswapd_single_memcg_param
    local memcg_zsmp=/dev/memcg/memory.zswapd_single_memcg_param

    tst_res TINFO "Start enhanced swap memory.zswapd_single_memcg_param \
                   interface test"
    echo 0 -100 0 0 > $memcg_100_zsmp
    ret=$(($ret + $?))
    echo 0 0 -100 0 > $memcg_100_zsmp
    ret=$(($ret + $?))
    echo 0 -100 -100 0 > $memcg_100_zsmp
    ret=$(($ret + $?))
    echo 0 101 101 0 > $memcg_100_zsmp
    ret=$(($ret + $?))

    echo 0 -100 0 0 > $memcg_zsmp
    ret=$(($ret + $?))
    echo 0 0 -100 0 > $memcg_zsmp
    ret=$(($ret + $?))
    echo 0 -100 -100 0 > $memcg_zsmp
    ret=$(($ret + $?))
    echo 0 101 101 0 > $memcg_zsmp
    ret=$(($ret + $?))

    if [ $ret -ne 8 ]; then
        res=$(($res + 1))
    fi

    if [ $res -eq 0 ]; then
        tst_res TPASS "enhanced swap memory.zswapd_single_memcg_param \
                       interface test pass."
    else
        tst_res TFAIL "enhanced swap memory.zswapd_single_memcg_param \
                       interface test failed!"
    fi
}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit