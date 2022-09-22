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
# File: enhancedf2fs01.sh
#
# Description: life mode, discard is greater than or equal to 512 block
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

     tst_res TINFO "Start test discard size >= 512 blocks in life mode."
     cat /sys/kernel/debug/tracing/trace_pipe | grep issue_discard >> log01.txt &
     mkdir /mnt/f2fs_mount/test1
     if [ $? -eq 0 ]; then
          tst_res TPASS "Created test1 dir successfully."
     else
          tst_res TFAIL "Created test1 dir failed."
          ret=$(( $ret + 1 ))
     fi
     local i=0
     while [ $i -lt 30 ]
     do
          dd if=/dev/zero of=/mnt/f2fs_mount/test1/image$i bs=8M count=1
          i=$(( $i + 1 ))
     done
     rm -rf /mnt/f2fs_mount/test1/image*[1,3,5,7,9]
     if [ $? -eq 0 ]; then
          tst_res TPASS "Deleted successfully."
     else
          tst_res TFAIL "Deleted fail."
          ret=$(( $ret + 1 ))
     fi

     sleep 240
     kill %1

     local blklen=$(cat log01.txt | awk 'NR == 1' | awk -F '0x' '{print$3}')
     if [ $((16#$blklen)) -ge 512 ]; then
          tst_res TPASS "blklen >= 512 successfully."
     else
          tst_res TFAIL "blklen >= 512 failed."
          ret=$(( $ret + 1 ))
     fi

     if [ $ret -eq 0 ]; then
          tst_res TPASS "discard is greater than or equal to 512 block pass."
     else
          tst_res TFAIL "discard is greater than or equal to 512 block failed!"
     fi
}

do_clean()
{
     rm log01.txt
     losetup -d /dev/block/loop1
     umount /mnt/f2fs_mount
}

do_setup
do_test
do_clean
tst_exit