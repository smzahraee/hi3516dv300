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
# File: enhancedswap01.sh
#
# Description: enhanced swap /dev/memcg/memory.avail_buffers interface test
#
# Authors:     Ma Feng - mafeng.ma@huawei.com
#
# History:     Mar 24 2022 - init scripts
#
################################################################################
source tst_oh.sh

do_setup()
{

}

do_test()
{
    local ret=0
    local res=0
    local memcg_availbffers=/dev/memcg/memory.avail_buffers

    tst_res TINFO "Start enhanced swap /dev/memcg/memory.avail_buffers \
                   interface invalid setting test"
    echo 0 1620 1529 0 > $memcg_availbffers
    ret=$(($ret + $?))
    echo 0 1620 -100 0 > $memcg_availbffers
    ret=$(($ret + $?))
    echo 0 -100 -100 0 > $memcg_availbffers
    ret=$(($ret + $?))
    echo 0 10000001 10000000 0 > $memcg_availbffers
    ret=$(($ret + $?))

    if [ $ret -ne 4 ]; then
        res=$(($res + 1))
    fi

    if [ $res -eq 0 ]; then
        tst_res TPASS "enhanced swap /dev/memcg/memory.avail_buffers \
                       interface invalid setting test pass."
    else
        tst_res TFAIL "enhanced swap /dev/memcg/memory.avail_buffers \
                       interface invalid setting test failed!"
    fi
}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit