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
# File: purgeable_mem01.sh
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
    (cd $(echo ${testpath%purgeable_cpp_test});chmod 777 purgeable_cpp_test;./purgeable_cpp_test >mylog.log)
    if [ $(grep -c -i "ok\|success\|true" ${testpath%purgeable_cpp_test}/mylog.log) -ne '0' ];then
        tst_res TINFO "purgeable_cpp_test executed success."
    else
        tst_res TFAIL "purgeable_cpp_test executed fail!"
    fi
    if [ $(grep -c -i "error\|fail\|false" ${testpath%purgeable_cpp_test}/mylog.log) -ne '0' ];then
        tst_res TFAIL "purgeable_cpp_test test error!"
    else
        tst_res TPASS "purgeable_cpp_test test pass."
    fi
    rm ${testpath%purgeable_cpp_test}/mylog.log
    ls ${testpath%purgeable_cpp_test} >log2.log
    local lastxml=$(tac log2.log | grep purgeable_cpp_test | grep xml| head -n 1)
    rm ${testpath%purgeable_cpp_test}${lastxml}
}

do_clean()
{
    rm log2.log
}


do_setup
do_test
do_clean
tst_exit
