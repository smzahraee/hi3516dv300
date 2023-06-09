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
# File: enhancedf2fs05.sh
#
# Description: performance mode, discard is greater than or equal to 1 block
#
# Authors:     Li Zhanming - lizhanming3@h-partners.com
#
# History:     April 8 2022 - init scripts
#
################################################################################

source tst_oh.sh

source performance_init.sh

do_setup()
{
     
}

do_test()
{
     local ret=0

     tst_res TINFO "Start test discard size >= 1 block in performance mode."

     cat /sys/kernel/debug/tracing/trace_pipe | grep issue_discard >> log05.txt &
     mkdir $DISK_PATH/test5
     if [ $? -eq 0 ]; then
          tst_res TPASS "Creation test5 dir successfully."
     else
          tst_res TFAIL "Creation test5 dir failed."
          ret=$(( $ret + 1 ))
     fi
     local i=0
     while [ $i -lt 200 ]
     do
          dd if=/dev/zero of=$DISK_PATH/test5/image$i bs=4k count=1
          i=$((i+1))
     done
     echo "y" | rm $DISK_PATH/test5/image*[1,3,5,7,9]
     if [ $? -eq 0 ]; then
          tst_res TPASS "Delete successfully."
     else
          tst_res TFAIL "Delete failed."
          ret=$(( $ret + 1 ))
     fi

     sleep 90
     kill %1
     local blklen=$(cat log05.txt | awk 'NR == 1' | awk -F '0x' '{print$3}')
     if [ $((16#$blklen)) -ge 1 ];then
          tst_res TPASS "blklen = $blklen >= 1 successfully."
     else
          tst_res TFAIL "blklen = $blklen >= 1 failed."
          ret=$(( $ret + 1 ))
     fi

     if [ $ret -eq 0 ];then
          tst_res TPASS "performance mode, discard is greater than or equal to  \
                         1 block pass."
     else
          tst_res TFAIL "performance mode, discard is greater than or equal to  \
                         1 block failed!"
     fi
}

do_clean()
{
     echo "y" | rm $DISK_PATH/test5/*
     rmdir $DISK_PATH/test5/
     echo "y" | rm $DISK_PATH/f2fs_test/*
     rmdir $DISK_PATH/f2fs_test/
}

do_setup
do_test
do_clean
tst_exit