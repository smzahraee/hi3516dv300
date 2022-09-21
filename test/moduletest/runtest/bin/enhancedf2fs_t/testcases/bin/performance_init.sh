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
# File: performance_init.sh
#
# Description: enhancedf2fs05 and enhancedf2fs06 testsuite init script
#
# Authors:     Li Zhanming - lizhanming3@h-partners.com
#
# History:     April 8 2022 - init scripts
#
################################################################################

source tst_oh.sh

state_init()
{
    mkfs.f2fs -d1 -t1 -O quota $IMG_FILE
    losetup /dev/block/loop1 $IMG_FILE
    mount -t f2fs /dev/block/loop1 /mnt/f2fs_mount/
}

performance_init()
{
    local ret=0
    local segs_path=/sys/kernel/debug/f2fs/status

    tst_res TINFO "Start performance_init.sh."
    local a=$(cat $segs_path | grep segs | awk -F ' ' '{print$3}')
    echo "start Embedded file system $(date +%Y%m%d%H%M%S)...." >> log06.txt
    local i=0
    while [ $i -lt 37 ]
    do
        dd if=/dev/zero of=/mnt/f2fs_mount/image$i bs=512M count=1
        i=$(( $i + 1 ))
    done
    echo "end Embedded file system $(date +%Y%m%d%H%M%S)...." >> log06.txt
    local b=$(cat $segs_path | grep "valid blocks" | awk -F ' ' '{print$3}' | tr -cd "[0-9]")
    local result_left=$(echo | awk "{print $a*512-$b}")
    local result_right=$(echo | awk "{print $a*512*0.1}")
    local result=$(echo "$result_left $result_right"  \
    | awk '{if ($result_left -lt $result_right) print 1; else print 0}')
    if [ $result -gt 0 ];then
        tst_res TPASS "Inequality holds."
    else
        tst_res TFAIL "Inequality does not hold."
        ret=$(( $ret + 1 ))
    fi

    sleep 60
    if [ $(cat /sys/fs/f2fs/loop1/discard_type) == '2' ];then
        tst_res TPASS "performance model successfully."
    else
        tst_res TFAIL "performance model failed."
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
        tst_res TPASS "performance_init successfully."
    else
        tst_res TFAIL "performance_init failed!"
    fi
}

state_init
performance_init
