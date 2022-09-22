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
# File: enhancedf2fs02.sh
#
# Description: life mode, discard is greater than or equal to 512 block
#              IO Imperceptible
#
# Authors:     Li Zhanming - lizhanming3@h-partners.com
#
# History:     April 8 2022 - init scripts
#
################################################################################

source tst_oh.sh

source life_init.sh

do_setup()
{

}

do_test()
{
    local ret=0

    tst_res TINFO "Start test discard size >= 512 blocks in life mode,IO imperceptible."


    cat /sys/kernel/debug/tracing/trace_pipe | grep issue_discard >> log02.txt &
    sh run_fio.sh > run_fio.txt &
    sleep 60
    mkdir /mnt/f2fs_mount/test2
    if [ $? -eq 0 ]; then
        tst_res TPASS "Created test2 dir successfully."
    else
        tst_res TFAIL "Created tets2 dir failed."
        ret=$(( $ret + 1 ))
    fi

    local i=0
    while [ $i -lt 30 ]
    do
        dd if=/dev/zero of=/mnt/f2fs_mount/test2/image$i bs=8M count=1
        i=$(( $i + 1 ))
    done
    rm -rf /mnt/f2fs_mount/test2/image*[1,3,5,7,9]
    if [ $? -eq 0 ]; then
        tst_res TPASS "Deleted successfully."
    else
        tst_res TFAIL "Deleted failed."
        ret=$(( $ret + 1 ))
    fi
    local first=$(wc -l log02.txt | awk -F ' ' '{print$1}')
    sleep 240
    local second=$(wc -l log02.txt | awk -F ' ' '{print$1}')
    sleep 90
    kill %1

    local err=$(cat run_fio.txt | grep err | awk -F ':' '{print$3}' | tr -cd "[0-9]")
    if [ $err -eq 0 ]; then
        tst_res TPASS "fio read successfully."
    else
        tst_res TFAIL "fio read failed."
        ret=$(( $ret + 1 ))
    fi

    local blklen=$(cat log02.txt | awk 'NR == 1' | awk -F '0x' '{print$3}')
    if [ $((16#$blklen)) -ge 512 ]; then
        tst_res TPASS "blklen >= 512 successfully."
    else
        tst_res TFAIL "blklen >= 512 failed."
        ret=$(( $ret + 1 ))
    fi

    if [ $(( $second - $first )) -gt 0 ]; then
        tst_res TPASS "IO perception test successfully."
    else
        tst_res TFAIL "IO perception test failed."
        ret=$(( $ret + 1 ))
    fi

    if [ $ret -eq 0 ];then
        tst_res TPASS "life mode, discard is greater than or equal to 512 block  \
                        IO Imperceptible pass."
    else
        tst_res TFAIL "life mode, discard is greater than or equal to 512 block  \
                        IO Imperceptible failed!"
    fi
}

do_clean()
{
    rm -rf log02.txt
    losetup -d /dev/block/loop1
    umount /mnt/f2fs_mount
}

do_setup
do_test
do_clean
tst_exit

