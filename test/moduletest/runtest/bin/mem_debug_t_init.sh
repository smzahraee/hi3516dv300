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
# File: mem_debug_t_init.sh
#
# Description: mem_debug_t testsuite init script
#
# Authors:     Wang Yuting - wangyuting36@huawei.com
#
# History:     May 25 2022 - init scripts
#
################################################################################

pre_condition()
{

}

hp_init()
{
    dd if=/dev/random of=/data/hpdisk bs=4096 count=131072
    losetup /dev/block/loop6 /data/hpdisk
    hyperhold_device=$(cat /proc/sys/kernel/hyperhold/device)
    echo /dev/block/loop6 > /proc/sys/kernel/hyperhold/device
}

hp_enable()
{
    hyperhold_enable=$(cat /proc/sys/kernel/hyperhold/enable)
    echo enable > /proc/sys/kernel/hyperhold/enable
}

zram_init()
{
    zram0_group=$(cat /sys/block/zram0/group)
    zram0_disksize=$(cat /sys/block/zram0/disksize)
    echo readwrite > /sys/block/zram0/group
    echo 512M > /sys/block/zram0/disksize
}

zram_enable()
{
    mkswap /dev/block/zram0
    swapon /dev/block/zram0
    aa start -b com.ohos.settings -a com.ohos.settings.MainAbility
    aa start -b ohos.samples.airquality -a ohos.samples.airquality.default
    aa start -b ohos.samples.ecg -a ohos.samples.ecg.MainAbility
    aa start -b ohos.samples.flashlight -a ohos.samples.flashlight.default
    aa start -b ohos.samples.clock -a ohos.samples.clock.default
}

echo "***************************MEMDEBUG INIT START***************************"
free -m
pre_condition
hp_init
hp_enable
zram_init
zram_enable
echo "***************************MEMDEBUG INIT END***************************"