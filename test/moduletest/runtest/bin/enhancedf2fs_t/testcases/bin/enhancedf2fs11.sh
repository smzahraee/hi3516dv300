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
    mkdir $DISK_PATH/f2fs_test
}

do_test()
{
    local ret=0
    local _sys_path=/sys/kernel/debug/tracing

    tst_res TINFO "Start test hierarchical SSR recycling is disabled."
    local i=0
    df -h | grep -w "$DISK_NAME" | awk -F " " '{print $4}' > 1.txt
    avail_mem=$(sed 's/.$//' 1.txt | cut -d '.' -f1)
    expected_mem=$(expr $avail_mem - 3)
    while [ $i -lt $expected_mem ]
    do
        dd if=/dev/zero of=$DISK_PATH/f2fs_test/image$i bs=1G count=1
        i=$(( $i + 1 ))
    done

    mkdir $DISK_PATH/test11
    local i=0
    while [ $i -lt 5120 ]
    do
        dd if=/dev/zero of=$DISK_PATH/test11/image$i bs=512k count=1
        i=$(( $i + 1 ))
    done
    echo "y" | rm $DISK_PATH/test11/image*[1,3,5,7,9]

    echo 0 > /sys/fs/f2fs/${DISK_NAME}/hc_enable
    echo 1 > $_sys_path/tracing_on
    echo 1 > $_sys_path/events/f2fs/f2fs_grading_ssr_allocate/enable

    cat $_sys_path/trace_pipe | grep ssr >> log11.txt &
    mkdir $DISK_PATH/test11/f2fs_grading_ssr_allocate
    local i=0
    while [ $i -lt 200 ]
    do
        dd if=/dev/zero of=$DISK_PATH/test11/f2fs_grading_ssr_allocate/image$i bs=4k count=1
        i=$(( $i + 1 ))
    done
    echo "y" | rm $DISK_PATH/test11/f2fs_grading_ssr_allocate/image*[1,3,5,7,9]

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
    
    echo "y" | rm 1.txt
}

do_clean()
{
    echo "y" | rm $DISK_PATH/test11/f2fs_grading_ssr_allocate/*
    rmdir $DISK_PATH/test11/f2fs_grading_ssr_allocate/
    echo "y" | rm $DISK_PATH/test11/*
    rmdir $DISK_PATH/test11/
    echo "y" | rm $DISK_PATH/f2fs_test/*
    rmdir $DISK_PATH/f2fs_test/
}

do_setup
do_test
do_clean
tst_exit