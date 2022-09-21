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
# File: mem_debug_t_uninit.sh
#
# Description: mem_debug_t testsuite uninit script
#
# Authors:     Wang Yuting - wangyuting36@huawei.com
#
# History:     May 26 2022 - init scripts
#
################################################################################

uninit_platform()
{
    losetup -d /dev/block/loop6
    echo ${hyperhold_device} > /proc/sys/kernel/hyperhold/device
    echo ${hyperhold_enable} > /proc/sys/kernel/hyperhold/enable
    echo ${zram0_group} > /sys/block/zram0/group
    echo ${zram0_disksize} > /sys/block/zram0/disksize
    rm -rf /data/hpdisk
    swapoff /dev/block/zram0
    echo 1 > /sys/block/zram0/reset
}

echo "***************************MEMDEBUG UNINIT START***************************"
free -m
uninit_platform
echo "***************************MEMDEBUG UNINIT END***************************"