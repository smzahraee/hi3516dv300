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
# File: enhancedf2fs12.sh
#
# Description: GC function test
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
    temp=$(cat /sys/fs/f2fs/loop1/gc_urgent)

    tst_res TINFO "Start test GC function."

    echo 1 > $_sys_path/tracing_on
    echo 1 > $_sys_path/events/f2fs/f2fs_background_gc/enable

    cat $_sys_path/trace_pipe | grep f2fs_background_gc >> log12.txt &
    local i=0
    while [ $i -lt 512 ]
    do
        dd if=/dev/zero of=/mnt/f2fs_mount/image$i bs=1M count=1
        i=$(( $i + 1 ))
    done
    rm -rf /mnt/f2fs_mount/image*[1,3,5,7,9]

    echo 1 > /sys/fs/f2fs/loop1/gc_urgent

    sleep 60
    kill %1

    if [ -s log12.txt ];then
        tst_res TPASS "log12.txt is not empty."
    else
        tst_res TFAIL "log12.txt empty."
        ret=$(( $ret + 1 ))
    fi
    if [ $ret -eq 0 ];then
        tst_res TPASS "GC function test pass."
    else
        tst_res TFAIL "GC function test failed!"
    fi
}

do_clean()
{
    rm -rf log12.txt
    echo $temp > /sys/fs/f2fs/loop1/gc_urgent
    losetup -d /dev/block/loop1 
    umount /mnt/f2fs_mount
}

do_setup
do_test
do_clean
tst_exit
