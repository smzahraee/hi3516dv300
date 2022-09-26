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
# File: enhancedf2fs07.sh
#
# Description: Hierarchical SSR control interface
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
    _ssr_path=/sys/fs/f2fs/loop1

    tst_res TINFO "Start test hierarchical SSR control interface."

    if [ $(cat $_ssr_path/hc_enable) == '0' ]; then
        tst_res TPASS "default is 0 successfully."
    else
        tst_res TFAIL "default not is 0 failed."
        ret=$(( $ret + 1 ))
    fi

    temp=$(cat $_ssr_path/hc_enable)
    echo 1 > $_ssr_path/hc_enable
    if [ $(cat $_ssr_path/hc_enable) == '1' ] && [ $ret -eq 0 ]; then
        tst_res TPASS "Hierarchical SSR control interface setting pass."
    else
        tst_res TFAIL "Hierarchical SSR control interface setting failed!"
    fi
}

do_clean()
{
    echo $temp > $_ssr_path/hc_enable
    losetup -d /dev/block/loop1 
    umount /mnt/f2fs_mount
}

do_setup
do_test
do_clean
tst_exit