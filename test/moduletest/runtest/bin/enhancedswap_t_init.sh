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
# File: enhancedswap_t_init.sh
#
# Description: enhancedswap_t testsuite init script
#
# Authors:     Ma Feng - mafeng.ma@huawei.com
#
# History:     Mar 24 2022 - init scripts
#
################################################################################

pre_condition()
{

}

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

hp_init()
{
    dd if=/dev/random of=hpdisk bs=4096 count=131072
    losetup /dev/block/loop7 hpdisk
    hyperhold_device=$(cat /proc/sys/kernel/hyperhold/device)
    echo /dev/block/loop7 > /proc/sys/kernel/hyperhold/device
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
    aa start -b com.ohos.camera -a com.ohos.camera.MainAbility                          
    aa start -b com.ohos.permissionmanager -a com.ohos.permissionmanager.MainAbility    
    aa start -b ohos.sample.shopping -a com.example.entry.MainAbility                   
    aa start -b ohos.samples.distributedcalc -a ohos.samples.distributedcalc.MainAbility

}

echo "***************************ESWAP INIT START***************************"
free -m
uninit_platform
pre_condition
hp_init
hp_enable
zram_init
zram_enable
echo "***************************ESWAP INIT END***************************"