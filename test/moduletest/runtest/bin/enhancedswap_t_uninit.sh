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
# File: enhancedswap_t_uninit.sh
#
# Description: enhancedswap_t testsuite uninit script
#
# Authors:     Ma Feng - mafeng.ma@huawei.com
#
# History:     Mar 24 2022 - init scripts
#
################################################################################

uninit_platform()
{
    losetup -d /dev/block/loop7
    echo ${hyperhold_device} > /proc/sys/kernel/hyperhold/device
    echo ${hyperhold_enable} > /proc/sys/kernel/hyperhold/enable
    echo ${zram0_group} > /sys/block/zram0/group
    echo ${zram0_disksize} > /sys/block/zram0/disksize
    rm -rf hpdisk
    swapoff /dev/block/zram0
    echo 1 > /sys/block/zram0/reset
}

echo "***************************ESWAP UNINIT START***************************"
free -m
uninit_platform
echo "***************************ESWAP UNINIT END***************************"