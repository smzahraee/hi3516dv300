#!/bin/sh
################################################################################
#
# Copyright (C) 2022 Huawei Device Co., Ltd.
# SPDX-License-Identifier: GPL-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
# File: enhancedf2fs10.sh
#
# Description: hierarchical SSR recovery function is enabled
#
# Authors:     Li Zhanming - lizhanming3@h-partners.com
#
# History:     April 8 2022 - init scripts
#
################################################################################

source tst_oh.sh

do_setup()
{
    mkdir $DISK_PATH/f2fs_test
}

do_test()
{
    local ret=0
    local _sys_path=/sys/kernel/debug/tracing

    tst_res TINFO "Start test hierarchical SSR recovery function is enabled."

    local i=0
    df -h | grep -w "$DISK_NAME" | awk -F " " '{print $4}' > 1.txt
    avail_mem=$(sed 's/.$//' 1.txt | cut -d '.' -f1)
    expected_mem=$(expr $avail_mem - 3)
    while [ $i -lt $expected_mem ]
    do
        dd if=/dev/zero of=$DISK_PATH/f2fs_test/image$i bs=1G count=1
        i=$(( $i + 1 ))
    done
    mkdir $DISK_PATH/test10
    local i=0
    while [ $i -lt 5120 ]
    do
        dd if=/dev/zero of=$DISK_PATH/test10/image$i bs=512k count=1
        i=$(( $i + 1 ))
    done
    echo "y" | rm $DISK_PATH/test10/image*[1,3,5,7,9]

    echo 1 > /sys/fs/f2fs/${DISK_NAME}/hc_enable
    echo 1 > $_sys_path/tracing_on
    echo 1 > $_sys_path/events/f2fs/f2fs_grading_ssr_allocate/enable

    cat $_sys_path/trace_pipe | grep ssr >> log10.txt &

    mkdir $DISK_PATH/test10/f2fs_grading_ssr_allocate
    local i=0
    while [ $i -lt 200 ]
    do
        dd if=/dev/zero of=$DISK_PATH/test10/f2fs_grading_ssr_allocate/image$i bs=4k count=1
        i=$(($i + 1))
    done
    echo "y" | rm $DISK_PATH/test10/f2fs_grading_ssr_allocate/image*[1,3,5,7,9]

    sleep 180
    kill %1

    if [ -s log10.txt ];then
        tst_res TPASS "log10.txt is not empty."
    else
        tst_res TFAIL "log10.txt empty."
        ret=$(( $ret + 1 ))
    fi

    if [ $ret -eq 0 ];then
        tst_res TPASS "The hierarchical SSR recovery function is enabled pass."
    else
        tst_res TFAIL "The hierarchical SSR recovery function is enabled failed!"
    fi
    
    echo "y" | rm 1.txt
}

do_clean()
{
    echo "y" | rm $DISK_PATH/test10/f2fs_grading_ssr_allocate/*
    rmdir $DISK_PATH/test10/f2fs_grading_ssr_allocate/
    echo "y" | rm $DISK_PATH/test10/*
    rmdir $DISK_PATH/test10/
    echo "y" | rm $DISK_PATH/f2fs_test/*
    rmdir $DISK_PATH/f2fs_test/
}

do_setup
do_test
do_clean
tst_exit