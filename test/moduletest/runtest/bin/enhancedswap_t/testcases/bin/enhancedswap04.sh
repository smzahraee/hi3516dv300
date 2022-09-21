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
# File: enhancedswap04.sh
#
# Description: anon memory to zram test
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
    local memcg_100_stat=/dev/memcg/100/memory.stat
    local memcg_stat=/dev/memcg/memory.stat
    avail_buffers=/dev/memcg/memory.avail_buffers
    local zswapd_s=/dev/memcg/memory.zswapd_pressure_show

    tst_res TINFO "Start anon to zram test"

    # get init zram values
    zram_100_b=$(cat ${memcg_100_stat} | grep 'zram' | awk -F ' ' '{print$2}')
    zram_b=$(cat ${memcg_stat} | grep 'zram' | awk -F ' ' '{print$2}')

    # get buffer_size
    buffer_size=$(cat $zswapd_s | grep 'buffer_size' | awk -F ':' '{print$2}')

    # get init avail_buffers  values
    avail_buffers_def=$(cat $avail_buffers | awk '$1=="avail_buffers:"{print $2}')
    min_avail_buffers_def=$(cat $avail_buffers | awk '$1=="min_avail_buffers:"{print $2}')
    high_avail_buffers_def=$(cat $avail_buffers | awk '$1=="high_avail_buffers:"{print $2}')
    free_swap_threshold_def=$(cat $avail_buffers | awk '$1=="free_swap_threshold:"{print $2}')

    # set avail_buffers > buffer_size to swap out to zram
    echo 0 $(( $buffer_size + 50 )) $(( $buffer_size + 100 )) 0 > $avail_buffers

    sleep 3

    # get new zram values after swap-out to zram
    zram_100_a=$(cat ${memcg_100_stat} | grep 'zram' | awk -F ' ' '{print$2}')
    zram_a=$(cat ${memcg_stat} | grep 'zram' | awk -F ' ' '{print$2}')

    tst_res TINFO "root zram: $zram_b --> $zram_a"
    tst_res TINFO "100 zram: $zram_100_b --> $zram_100_a"

    # zram change
    if [[ $zram_b -ne $zram_a || $zram_100_b -ne $zram_100_a ]]; then
        tst_res TINFO "anon memory compressed to zram, Eswap hold."
    else
        tst_res TINFO "no anon memory compressed to zram!"
        ret=$(( $ret + 1 ))
    fi

    if [ $ret -eq 0 ];then
        tst_res TPASS "anon memory to zram test pass."
    else
        tst_res TFAIL "anon memory to zram test failed!"
    fi
}

do_clean()
{
    # set avail_buffers_def > buffer_size
    echo $avail_buffers_def $min_avail_buffers_def $high_avail_buffers_def $free_swap_threshold_def > $avail_buffers
}

do_setup
do_test
do_clean
tst_exit