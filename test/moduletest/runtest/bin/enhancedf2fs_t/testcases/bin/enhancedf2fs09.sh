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
# File: enhancedf2fs09.sh
#
# Description: Hierarchical SSR waterline configuration interface
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
    ret=0
    _ssr_path=/sys/fs/f2fs/loop1

    tst_res TINFO "Start test hierarchical SSR waterline configuration interface."

    init_value1=$(cat $_ssr_path/hc_hot_data_waterline)
    init_value2=$(cat $_ssr_path/hc_warm_data_waterline)
    init_value3=$(cat $_ssr_path/hc_hot_node_waterline)
    init_value4=$(cat $_ssr_path/hc_warm_node_waterline)

    confirm_value hc_hot_data_waterline &&
    confirm_value hc_warm_data_waterline &&
    confirm_value hc_hot_node_waterline &&
    confirm_value hc_warm_node_waterline

    [ $? -ne 0 ] && ret=$(( $ret + 1 ))

    echo 85 > $_ssr_path/hc_hot_data_waterline
    echo 85 > $_ssr_path/hc_warm_data_waterline
    echo 85 > $_ssr_path/hc_hot_node_waterline
    echo 85 > $_ssr_path/hc_warm_node_waterline

    confirm_change_value hc_hot_data_waterline &&
    confirm_change_value hc_warm_data_waterline &&
    confirm_change_value hc_hot_data_waterline &&
    confirm_change_value hc_warm_node_waterline

    [ $? -ne 0 ] && ret=$(( $ret + 1 ))

    if [ $ret -eq 0 ];then
        tst_res TPASS "Hierarchical SSR waterline configuration interface pass."
    else
        tst_res TFAIL "Hierarchical SSR waterline configuration interface failed."
    fi
}

confirm_value()
{
    if [ $(cat $_ssr_path/$1) == '80' ];then
        tst_res TPASS "$1 Value is 80 successfully."
        return 0
    else
        tst_res TFAIL "$1 Value not is 80 failed."
        return 1
    fi
}

confirm_change_value()
{
    if [ $(cat $_ssr_path/$1) == '85' ];then
        tst_res TPASS "$1 Value is 85 successfully."
        return 0
    else
        tst_res TFAIL "$1 Value not is 85 failed."
        return 1
    fi
}

do_clean()
{
    echo $init_value1 > $_ssr_path/hc_hot_data_waterline
    echo $init_value2 > $_ssr_path/hc_warm_data_waterline
    echo $init_value3 > $_ssr_path/hc_hot_node_waterline
    echo $init_value4 > $_ssr_path/hc_warm_node_waterline
    losetup -d /dev/block/loop1
    umount /mnt/f2fs_mount
}

do_setup
do_test
do_clean
tst_exit