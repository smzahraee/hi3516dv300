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
# File: equilibrium_init.sh
#
# Description: enhancedf2fs03 and enhancedf2fs04 testsuite init script
#
# Authors:     Li Zhanming - lizhanming3@h-partners.com
#
# History:     Mar 15 2022 - init scripts
#
################################################################################

source tst_oh.sh

state_init()
{
    mkfs.f2fs -d1 -t1 -O quota $IMG_FILE
    losetup /dev/block/loop1 $IMG_FILE
    mount -t f2fs /dev/block/loop1 /mnt/f2fs_mount/
}

equilibrium_init()
{
    local ret=0
    local segs_path=/sys/kernel/debug/f2fs/status

    tst_res TINFO "Start equilibrium_init.sh."
    local a=$(cat $segs_path | grep segs | awk -F ' ' '{print$3}')

    local i=0
    while [ $i -lt 32 ]
    do
        dd if=/dev/zero of=/mnt/f2fs_mount/image$i bs=512M count=1
        i=$(( $i + 1 ))
    done

    local b=$(cat $segs_path | grep "valid blocks" | awk -F ' ' '{print$3}' | tr -cd "[0-9]")
    local result_left=$(echo | awk "{peint $a*512*0.2}")
    local result_might=$(echo | awk "{print $a*512-$b}")
    local result_right=$(echo | awk "{print $a*512*0.1}")
    local result1=$(echo "$result_left $result_might"  \
    | awk '{if ($result_left -gt $result_might) print 1; else print 0}')
    local result2=$(echo "$result_might $result_right"  \
    | awk '{if ($result_might -gt $result_right) print 1; else print 0}')
    if [ $result1 -gt 0 ] && [ $result2 -gt 0 ]; then
        tst_res TPASS "Inequality holds."
    else
        tst_res TFAIL "Inequality does not hold."
        ret=$(( $ret + 1 ))
    fi

    sleep 60
    if [ $(cat /sys/fs/f2fs/loop1/discard_type) == '1' ];then
        tst_res TPASS "equilibrium model successfully."
    else
        tst_res TFAIL "equilibrium model failed."
        ret=$(( $ret + 1 ))
    fi

    echo 1 > /sys/kernel/debug/tracing/tracing_on
    echo 1 > /sys/kernel/debug/tracing/events/f2fs/f2fs_issue_discard/enable
    if [ $? -eq 0 ]; then
        tst_res TPASS "Trace opened successfully."
    else
        tst_res TFAIL "Trace start failed."
        ret=$(( $ret + 1 ))
    fi

    if [ $ret -eq 0 ];then
        tst_res TPASS "equilibrium_init successfully."
    else
        tst_res TFAIL "equilibrium_init failed!"
    fi
}

state_init
equilibrium_init
