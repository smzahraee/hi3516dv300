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
# File: mem_debug08.sh
#
# Description:  Ashmem information display test
#
# Authors:     Wangyuting - wangyuting36@huawei.com
#
# History:     Mar 23 2022 - init scripts
#
################################################################################
source tst_oh.sh

do_setup()
{

}

do_test()
{
    # find ashmem process
    local pid=$(cat /proc/ashmem_process_info | awk 'NR>3 && $2!="" {print $2}' | sort -u)
    local line=$(cat /proc/ashmem_process_info | awk 'NR>3 && $2!="" {print $2}' | sort -u | wc -l)
    if [ $line -eq 0 ]; then
        tst_res TFAIL "Cannot find program with ashmen!"
    else
        tst_res TPASS "The following $line ashmem processes have been found(PID): $pid."
    fi

    # Confirm that each process ashmem information is correct
    for p in $pid
    do
        tst_res TINFO "now going to check $p ashmem information"
        ash_info_check $p
    done

}

ash_info_check()
{
    local pid=$1
    tst_res TINFO "pid is $pid ."

    local ashmem_info_lines=$(cat /proc/$pid/smaps | grep ashmem | wc -l)

    if [ $ashmem_info_lines -le 0 ]; then
        tst_res TFAIL "Cannot find ashmem information of $pid .Ashmem information display test failed!"
    else
        tst_res TPASS "$pid totally found $ashmem_info_lines ashmem messages.Ashmem information display test pass."
    fi
}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit