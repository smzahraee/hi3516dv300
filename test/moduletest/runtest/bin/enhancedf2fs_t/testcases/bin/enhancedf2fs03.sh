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
# File: enhancedf2fs03.sh
#
# Description: equilibrium mode, discard is greater than or equal to 16 block
#
# Authors:     Li Zhanming - lizhanming3@h-partners.com
#
# History:     April 8 2022 - init scripts
#
################################################################################

source tst_oh.sh

source equilibrium_init.sh

do_setup()
{

}

do_test()
{
     local ret=0

     tst_res TINFO "Start test discard size >= 16 blocks in equilibrium mode."

     cat /sys/kernel/debug/tracing/trace_pipe | grep issue_discard >> log03.txt &
     sleep 60
     mkdir /mnt/f2fs_mount/test3
     if [ $? -eq 0 ]; then
          tst_res TPASS "Creation test3 dir successfully."
     else
          tst_res TFAIL "Creation test3 dir fail."
          ret=$(( $ret + 1 ))
     fi

     local i=0
     while [ $i -lt 50 ]
     do
          dd if=/dev/zero of=/mnt/f2fs_mount/test3/image$i bs=512K count=1
          i=$(( $i + 1 ))
     done
     rm -rf /mnt/f2fs_mount/test3/image*[1,3,5,7,9]
     if [ $? -eq 0 ]; then
          tst_res TPASS "Deleted successfully."
     else
          tst_res TFAIL "Deleted fail."
          ret=$(( $ret + 1 ))
     fi

     sleep 90
     kill %1

     local blklen=$(cat log03.txt | awk 'NR == 1' | awk -F '0x' '{print$3}')
     if [ $((16#$blklen)) -ge 16 ];then
          tst_res TPASS "blklen >= 16 successfully."
     else
          tst_res TFAIL "Log printing fail."
          ret=$(( $ret + 1 ))
     fi

     if [ $ret -eq 0 ];then
          tst_res TPASS "equilibrium mode, discard is greater than or equal to  \
                         16 block pass."
     else
          tst_res TFAIL "equilibrium mode, discard is greater than or equal to  \
                         16 block failed!"
     fi
}

do_clean()
{
     rm -rf log03.txt
     losetup -d /dev/block/loop1
     umount /mnt/f2fs_mount
}

do_setup
do_test
do_clean
tst_exit