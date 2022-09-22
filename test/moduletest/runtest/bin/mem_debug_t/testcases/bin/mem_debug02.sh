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
# File: mem_debug02.sh
#
# Description: Sum of static memory excluding cma test
#
# Authors:     Wangyuting - wangyuting36@huawei.com
#
# History:     Mar 23 2022 - init scripts
#
################################################################################
source tst_oh.sh

do_setup()
{
    zcat /proc/config.gz | grep CONFIG_DEBUG_FS=y || tst_res TCONF "CONFIG_DEBUG_FS=y not satisfied!"
}

do_test()
{
    local code_low_add=$( cat /proc/iomem | grep Kernel | awk '$4=="code"{print $1}' | awk 'BEGIN{FS="-"}{print $1}')
    local code_high_add=$( cat /proc/iomem | grep Kernel | awk '$4=="code"{print $1}' | awk 'BEGIN{FS="-"}{print $2}')
    local code_size=$((16#$code_high_add - 16#$code_low_add))

    local data_low_add=$( cat /proc/iomem | grep Kernel | awk '$4=="data"{print $1}' | awk 'BEGIN{FS="-"}{print $1}')
    local data_high_add=$( cat /proc/iomem | grep Kernel | awk '$4=="data"{print $1}' | awk 'BEGIN{FS="-"}{print $2}')
    local data_size=$((16#$data_high_add - 16#$data_low_add))

    local kernel_size=$(($code_size + $data_size))
    local ksize_kb=$(($kernel_size / 1024))

    local memtotal=$(cat /proc/meminfo | awk '$1=="MemTotal:"{print $2}')
    local total_size=$(($ksize_kb + $memtotal))
    local maxsize=$((2 * 1024 * 1024))

    if [ $total_size -le $maxsize ]; then
        tst_res TPASS "Sum of static memory excluding cma test pass."
    else
        tst_res TFAIL "Sum of static memory excluding cma test failed!"
    fi
}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit