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
# File: mem_debug05.sh
#
# Description: Dimension measurement information of DR/kswapd/zswapd test
#
# Authors:     Wangyuting - wangyuting36@huawei.com
#
# History:     Mar 23 2022 - init scripts
#
################################################################################
source tst_oh.sh

do_setup()
{
    zcat /proc/config.gz | grep CONFIG_RECLAIM_ACCT=y || tst_res TCONF "CONFIG_RECLAIM_ACCT=y not satisfied!"

    avail_buffers=/dev/memcg/memory.avail_buffers

    local zswapd_s=/dev/memcg/memory.zswapd_pressure_show
    local buffer_size=$(cat $zswapd_s | grep 'buffer_size' | awk -F ':' '{print$2}')

    avail_buffers_def=$(cat /dev/memcg/memory.avail_buffers | awk '$1=="avail_buffers:"{print $2}')
    min_avail_buffers_def=$(cat /dev/memcg/memory.avail_buffers | awk '$1=="min_avail_buffers:"{print $2}')
    high_avail_buffers_def=$(cat /dev/memcg/memory.avail_buffers | awk '$1=="high_avail_buffers:"{print $2}')
    free_swap_threshold_def=$(cat /dev/memcg/memory.avail_buffers | awk '$1=="free_swap_threshold:"{print $2}')

    echo 0 $(( $buffer_size + 50 )) $(( $buffer_size + 100 )) 0 > $avail_buffers
    sleep 3
}

do_test()
{
    local ret=0

    reclaim_acct_disable="/sys/module/reclaim_acct/parameters/disable"
    reclaim_acct_disable_def=$(cat /sys/module/reclaim_acct/parameters/disable)
    echo 0 > $reclaim_acct_disable

    wukong exec -s 10 -i 1000 -a 0.28 -t 0.72 -c 1000000 &
    sleep 100

    check_reclaim_efficiency "reclaim"
    check_reclaim_efficiency "kswapd"
    check_reclaim_efficiency "zswapd"

}

check_reclaim_efficiency()
{
    local mem_type=$1

    cat /proc/reclaim_efficiency > log.txt
    local total_process_time=$(cat log.txt | grep -A5 $mem_type | grep total_process | awk '{print $2}')
    local drain_pages_time=$(cat log.txt | grep -A5 $mem_type | grep drain_pages | awk '{print $2}')
    local shrink_file_time=$(cat log.txt | grep -A5 $mem_type | grep shrink_file | awk '{print $2}')
    local shrink_anon_time=$(cat log.txt | grep -A5 $mem_type | grep shrink_anon | awk '{print $2}')
    local shrink_slab_time=$(cat log.txt | grep -A5 $mem_type | grep shrink_slab | awk '{print $2}')
    local sum_time_a=$(($drain_pages_time + $shrink_file_time))
    local sum_time_b=$(($shrink_anon_time + $shrink_slab_time))
    local sum_time=$(($sum_time_a + $sum_time_b))

    if [ $sum_time -le $total_process_time ]; then
        tst_res TPASS "total_process_time in $mem_type isn't less than sum of subprocess."
    else
        tst_res TFAIL "total_process_time in $mem_type is less than sum of subprocess."
    fi

    local total_process_freed=$(cat log.txt | grep -A5 $mem_type | grep total_process | awk '{print $3}')
    local shrink_file_freed=$(cat log.txt | grep -A5 $mem_type | grep shrink_file | awk '{print $3}')
    local shrink_anon_freed=$(cat log.txt | grep -A5 $mem_type | grep shrink_anon | awk '{print $3}')
    local sum_freed=$(($shrink_file_freed + $shrink_anon_freed))

    if [ $sum_freed -eq $total_process_freed ]; then
        tst_res TPASS "total_process_freed in $mem_type calculate correctly."
    else
        tst_res TFAIL "total_process_freed in $mem_type calculate incorrectly."
    fi
}

do_clean()
{
    local pid=$(ps -ef | grep wukong | grep -v grep | awk '{print $2}')
    kill -9 $pid
    echo $reclaim_acct_disable_def > $reclaim_acct_disable
    echo $avail_buffers_def $min_avail_buffers_def $high_avail_buffers_def $free_swap_threshold_def > $avail_buffers
    rm -rf log.txt
}

do_setup
do_test
do_clean
tst_exit