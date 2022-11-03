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
# File: purgeable_mem03.sh
#
# Description: Static memory reservation query test
#
# Authors:     Ke Liu - liuke94@huawei.com
#
# History:     Nov 2 2022 - init scripts
#
################################################################################
source tst_oh.sh

do_setup()
{
    zcat /proc/config.gz | grep CONFIG_MEM_PURGEABLE=y || tst_res TCONF "CONFIG_MEM_PURGEABLE=y not satisfied!"
}

do_test()
{
    local testpath=$(find / -name purgeable_cpp_test | grep -v find)
    if [ ! $testpath ];then
        tst_res TFAIL "can not find purgeable_cpp_test!"
    fi
    (cd $(echo ${testpath%purgeable_cpp_test});chmod 777 purgeable_cpp_test;./purgeable_cpp_test &>/dev/null &)
    local pid= $(pidof purgeable_cpp_test)
    while [ "$pid" -eq '0' ]
    do
        pid=$(pidof purgeable_cpp_test)
    done
    while [ "$pid" -ne '0' ]
    do
        cat /proc/${pid}/status | grep -i purg | grep -v grep | grep -v Name >>mem.log
        pid=$(pidof purgeable_cpp_test)
    done
    cat mem.log | grep -v '0 kB' >mem1.log
    if [ -s mem1.log ];then
        tst_res TPASS "Purgeable memory reservation query test pass."
    else
        tst_res TFAIL "Purgeable memory reservation query test error!"
    fi
    ls ${testpath%purgeable_cpp_test} >log2.log
    local lastxml=$(tac log2.log | grep purgeable_cpp_test | grep xml| head -n 1)
    rm ${testpath%purgeable_cpp_test}${lastxml}
}

do_clean()
{
    rm mem.log
    rm mem1.log
    rm log2.log
}

do_setup
do_test
do_clean
tst_exit
