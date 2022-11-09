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
    mkdir $DISK_PATH/f2fs_test
}

performance_init()
{
    local ret=0
    local segs_path=/sys/kernel/debug/f2fs/status

    tst_res TINFO "Start performance_init.sh."
    local a=$(cat $segs_path | grep segs | awk -F ' ' '{print$3}')
    echo "start Embedded file system $(date +%Y%m%d%H%M%S)...." >> log06.txt
    local i=0
    df -h | grep -w "$DISK_NAME" | awk -F " " '{print $2}' > 1.txt
    total_mem=$(sed 's/.$//' 1.txt)
    mid_mem=$(expr $total_mem \* 90)
    expected_mem=$(expr $mid_mem / 100)
    while [ $i -lt $expected_mem ]
    do
        dd if=/dev/zero of=$DISK_PATH/f2fs_test/image$i bs=1G count=1
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
    if [ $(cat /sys/fs/f2fs/${DISK_NAME}/discard_type) == '2' ];then
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

    echo "y" | rm 1.txt
}

state_init
performance_init
