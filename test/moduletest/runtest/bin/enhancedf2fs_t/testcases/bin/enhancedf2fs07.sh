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

}

do_test()
{
    local ret=0
    _ssr_path=/sys/fs/f2fs/${DISK_NAME}

    tst_res TINFO "Start test hierarchical SSR control interface."

    if [ $(cat $_ssr_path/hc_enable) == '0' ]; then
        tst_res TPASS "$_ssr_path default is 0 successfully."
    else
        tst_res TFAIL "$_ssr_path default not is 0 failed."
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
}

do_setup
do_test
do_clean
tst_exit