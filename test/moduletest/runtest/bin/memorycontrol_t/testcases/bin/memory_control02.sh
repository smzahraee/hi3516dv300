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
# File: memory_control02.sh
#
# Description: Verify /dev/memcg/memory.ub_ufs2zram_ratio
#
# Authors:     Wu Lisai - wulisai@huawei-partners.com
#
# History:     Nov 18 2022 - init scripts
#
################################################################################
source tst_oh.sh

do_setup()
{
	zcat /proc/config.gz | grep CONFIG_HYPERHOLD_MEMCG=y || tst_res TCONF "CONFIG_HYPERHOLD_MEMCG=y not satisfied!"
}

do_test()
{
        tst_res TINFO "Start to verify mem ."

        mem=$(cat /dev/memcg/memory.ub_ufs2zram_ratio)

        if [ "$mem"x = "0"x ]; then
               tst_res TPASS "memory_control default value correct."
        else
               tst_res TFAIL "memory_control default value incorrect."
        fi

}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit
