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
# File: enhancedf2fs08.sh
#
# Description: Hierarchical SSR threshold configuration interface
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

    tst_res TINFO "Start test hierarchical SSR threshold configuration interface."

    init_value1=$(cat $_ssr_path/hc_hot_data_lower_limit)
    init_value2=$(cat $_ssr_path/hc_warm_data_lower_limit)
    init_value3=$(cat $_ssr_path/hc_hot_node_lower_limit)
    init_value4=$(cat $_ssr_path/hc_warm_node_lower_limit)

    confirm_value hc_hot_data_lower_limit &&
    confirm_value hc_warm_data_lower_limit &&
    confirm_value hc_hot_node_lower_limit &&
    confirm_value hc_warm_node_lower_limit

    [ $? -ne 0 ] && ((ret++))

    echo 6000000 > $_ssr_path/hc_hot_data_lower_limit
    echo 6000000 > $_ssr_path/hc_warm_data_lower_limit
    echo 6000000 > $_ssr_path/hc_hot_node_lower_limit
    echo 6000000 > $_ssr_path/hc_warm_node_lower_limit

    confirm_change_value hc_hot_data_lower_limit &&
    confirm_change_value hc_warm_data_lower_limit &&
    confirm_change_value hc_hot_node_lower_limit &&
    confirm_change_value hc_warm_node_lower_limit

    [ $? -ne 0 ] && ((ret++))

    if [ $ret -eq 0 ];then
        tst_res TPASS "hierarchical SSR threshold configuration interface pass."
    else
        tst_res TFAIL "Hierarchical SSR threshold configuration interface failed!"
    fi
}

confirm_value()
{
    local result_out1=$(cat /sys/fs/f2fs/loop1/$1)
    if [ "$result_out1" == "5242880" ]; then
        tst_res TPASS "$1 is 5242880 expected."
        return 0
    else
        tst_res TFAIL "$1 is not 5242880 unexpected!"
        return 1
    fi
}

confirm_change_value()
{
    local result_out2=$(cat /sys/fs/f2fs/loop1/$1)
    if [ "$result_out2" == "6000000" ]; then
        tst_res TPASS "$1 is 6000000 expected."
    else
        tst_res TFAIL "$1 is not 6000000 unexpected!"
        return 0
    fi
}

do_clean()
{
    echo $init_value1 > $_ssr_path/hc_hot_data_lower_limit
    echo $init_value2 > $_ssr_path/hc_warm_data_lower_limit
    echo $init_value3 > $_ssr_path/hc_hot_node_lower_limit
    echo $init_value4 > $_ssr_path/hc_warm_node_lower_limit
    losetup -d /dev/block/loop1
    umount /mnt/f2fs_mount
}

do_setup
do_test
do_clean
tst_exit