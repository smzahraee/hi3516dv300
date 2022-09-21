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
# File: life_init.sh
#
# Description: enhancedf2fs01 and enhancedf2fs02 testsuite init script
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

life_init()
{
    local ret=0
    local _segs_path=/sys/kernel/debug/f2fs/status
    local _sys_path=/sys/kernel/debug/tracing

    tst_res TINFO "Start life_init.sh."

    local a=$(cat $_segs_path | grep segs | awk -F ' ' '{print$3}')
    local b=$(cat $_segs_path| grep "valid blocks" | awk -F ' ' '{print$3}' | tr -cd "[0-9]")
    local result_left=$(echo | awk "{print $a*512-$b}")
    local result_right=$(echo | awk "{print $a*512*0.2}")
    local result=$(echo "$result_left $result_right"  \
    | awk '{if ($result_left -gt $result_right) print 1; else print 0}')
    if [ $result -gt 0 ]; then
        tst_res TPASS "Inequality holds."
    else
        tst_res TFAIL "Inequality does not hold."
        ret=$(( $ret + 1 ))
    fi

    if [ $(cat /sys/fs/f2fs/loop1/discard_type) == '0' ];then
        tst_res TPASS "life model successfully."
    else
        tst_res TFAIL "life model failed."
        ret=$(( $ret + 1 ))
    fi

    echo 1 > $_sys_path/tracing_on
    echo 1 > $_sys_path/events/f2fs/f2fs_issue_discard/enable
    if [ $? -eq 0 ];then
        tst_res TPASS "Trace opened successfully."
    else
        tst_res TFAIL "Trace start failed."
        ret=$(( $ret + 1 ))
    fi
    if [ $ret -eq 0 ];then
        tst_res TPASS "life_init pass."
    else
        tst_res TFAIL "life_init failed!"
    fi
}

state_init
life_init
