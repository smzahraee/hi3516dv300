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
# File: mem_debug01.sh
#
# Description: Static memory reservation query test
#
# Authors:     Wangyuting - wangyuting36@huawei.com
#
# History:     Mar 19 2022 - init scripts
#
################################################################################
source tst_oh.sh

do_setup()
{
    zcat /proc/config.gz | grep CONFIG_DEBUG_FS=y || tst_res TCONF "CONFIG_DEBUG_FS=y not satisfied!"
}

do_test()
{
    local rmem_lines=$(cat /sys/kernel/debug/dt_reserved_mem/dt_reserved_memory | wc -l)

    if [ $rmem_lines -gt 1 ]; then
        tst_res TPASS "Static memory reservation query test pass."
    else
        tst_res TFAIL "Static memory reservation query test failed!"
    fi
}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit