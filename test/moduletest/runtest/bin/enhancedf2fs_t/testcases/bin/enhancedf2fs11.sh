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
# File: enhancedf2fs11.sh
#
# Description: Hierarchical SSR recycling is disabled
#
# Authors:     Li Zhanming - lizhanming3@h-partners.com
#
# History:     April 8 2022 - init scripts
#
################################################################################

source tst_oh.sh

do_setup()
{
    mkfs.f2fs -d1 -t1 -O quota $IMG_FILE
    losetup /dev/block/loop1 $IMG_FILE
    mount -t f2fs /dev/block/loop1 /mnt/f2fs_mount/
}

do_test()
{
    local ret=0
    local _sys_path=/sys/kernel/debug/tracing

    tst_res TINFO "Start test hierarchical SSR recycling is disabled."
    local i=0
    while [ $i -lt 32 ]
    do
        dd if=/dev/zero of=/mnt/f2fs_mount/image$i bs=512M count=1
        i=$(( $i+ 1 ))
    done

    mkdir /mnt/f2fs_mount/test11
    local i=0
    while [ $i -lt 5120 ]
    do
        dd if=/dev/zero of=/mnt/f2fs_mount/test11/image$i bs=512k count=1
        i=$(( $i + 1 ))
    done
    rm -rf /mnt/f2fs_mount/test11/image*[1,3,5,7,9]

    echo 0 > /sys/fs/f2fs/loop1/hc_enable
    echo 1 > $_sys_path/tracing_on
    echo 1 > $_sys_path/events/f2fs/f2fs_grading_ssr_allocate/enable

    cat $_sys_path/trace_pipe | grep ssr >> log11.txt &
    mkdir /mnt/f2fs_mount/test11/f2fs_grading_ssr_allocate
    local i=0
    while [ $i -lt 200 ]
    do
        dd if=/dev/zero of=/mnt/f2fs_mount/test11/f2fs_grading_ssr_allocate/image$i bs=4k count=1
        i=$(( $i + 1 ))
    done
    rm -rf /mnt/f2fs_mount/test11/f2fs_grading_ssr_allocate/image*[1,3,5,7,9]

    sleep 180
    kill %1

    if [ -s log11.txt ];then
        tst_res TFAIL "log11.txt is not empty."
        ret=$(( $ret + 1 ))
    else
        tst_res TPASS "log11.txt empty."
    fi

    if [ $ret -eq 0 ];then
        tst_res TPASS "Hierarchical SSR recycling is disabled pass."
    else
        tst_res TFAIL "Hierarchical SSR recycling is disabled failed!"
    fi
}

do_clean()
{
    rm -rf log11.txt
    losetup -d /dev/block/loop1
    umount /mnt/f2fs_mount
}

do_setup
do_test
do_clean
tst_exit