#!/bin/sh
################################################################################
#
# Copyright (C) 2022 Huawei Device Co., Ltd.
# SPDX-License-Identifier: GPL-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
# File: enhancedswap05.sh
#
# Description: zram to Eswap test
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
    local memcg_eswap=/dev/memcg/memory.eswap_info
    local avail_buffers=/dev/memcg/memory.avail_buffers
    local zswapd_s=/dev/memcg/memory.zswapd_pressure_show

    tst_res TINFO "Start zram to Eswap test"
    # get init Eswap values
    eswap_100_b=$(cat ${memcg_100_stat} | grep 'Eswap' | awk -F ' ' '{print$2}')
    eswap_b=$(cat ${memcg_eswap} | awk -F ' ' '{print$4}')

    # turn on enhanced swap out
    echo 30 > /dev/memcg/memory.zram_wm_ratio
    echo 60 10 50 > /dev/memcg/memory.zswapd_single_memcg_param

    # get buffer_size
    buffer_size=$(cat $zswapd_s | grep 'buffer_size' | awk -F ':' '{print$2}')

    # set avail_buffers > buffer_size to swap out to Eswap
    echo $(( $buffer_size + 180 )) $(( $buffer_size + 150 )) $(( $buffer_size + 200 )) 0 > $avail_buffers

    sleep 3

    # get new Eswap values after swap-out to Eswap
    eswap_100_a=$(cat ${memcg_100_stat} | grep 'Eswap' | awk -F ' ' '{print$2}')
    eswap_a=$(cat ${memcg_eswap} | awk -F ' ' '{print$4}')

    tst_res TINFO "root Eswap: $eswap_b --> $eswap_a"
    tst_res TINFO "100 Eswap: $eswap_100_b --> $eswap_100_a"

    # Eswap change
    if [[ $eswap_b -ne $eswap_a || $eswap_100_b -ne $eswap_100_a ]]; then
        tst_res TINFO "zram to Eswap."
    else
        tst_res TINFO "no zram to Eswap."
        ret=$(( $ret + 1 ))
    fi

    if [ $ret -eq 0 ];then
        tst_res TPASS "zram to Eswap test pass."
    else
        tst_res TFAIL "zram to Eswap test failed!"
    fi
}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit
