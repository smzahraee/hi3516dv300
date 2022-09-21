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
# File: cpuisolation03.sh
#
# Description: check CPU lightweight isolation Power up and down function
#
# Authors:     liudanning - liudanning@h-partners.com
#
# History:     Mar 24 2022 - init scripts
#
################################################################################

source tst_oh.sh

do_setup()
{
    touch isolated_cpu1.txt
    touch active_cpu1.txt
    touch isolated_cpu2.txt
    touch active_cpu2.txt
}

do_test()
{
    ret=0
    dir_name=/sys/devices/system/cpu/cpu0/core_ctl
    global_state=$dir_name/global_state
    proc_sd=/proc/sched_debug

    tst_res TINFO "Start to check CPU isolation Power up and down function."
    sh create_process.sh 40
    sleep 5

    echo 2 > /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
    check_isolation
    check_movement
    isolated_cpu_online
    active_cpu_online
    echo "ret=$ret"
    if [ $ret -eq 0 ]; then
        tst_res TPASS "CPU isolation Power up and down function success."
    else
        tst_res TFAIL "CPU isolation Power up and down function failed!"
    fi

    echo 4 > /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
}

check_isolation()
{
    cpu_total=$(cat /proc/cpuinfo | grep "processor" | wc -l)
    cpu_total=$(( ${cpu_total} - 1 ))
    active_num=0
    isolated_num=0
    for i in $(seq 0 ${cpu_total}); do
        line=$(( $i + 1))
        cpu_isolated_state=$(cat $global_state | grep 'Isolated:'  \
        | sed -n "${line}p" | awk -F ':' '{print$2}')
        if [ $cpu_isolated_state -eq 0 ]; then
            tst_res TINFO "cpu$i is active."
            active_num=$(( $active_num + 1 ))
            echo $i >> active_cpu1.txt
        else
            tst_res TINFO "cpu$i is isolated."
            isolated_num=$(( $isolated_num + 1 ))
            echo $i >> isolated_cpu1.txt
        fi
    done
    if [[ $active_num -eq 2 ]] && [[ $isolated_num -eq 2 ]];then
        tst_res TPASS "two cpus is active,and two cpus is isolated."
    else
        tst_res TFAIL "the cpus state error."
        ((ret++))
    fi

    cpu_num=$(cat isolated_cpu1.txt | sed -n "1p" )
    echo 0 > /sys/devices/system/cpu/cpu${cpu_num}/online
    cpu_number=$(( $cpu_num + 1 ))
    cpu_online_state=$(cat $global_state | grep 'Online:'  \
    | sed -n "${cpu_number}p" | awk -F ':' '{print$2}')
    if [ ${cpu_online_state} -eq 0 ];then
        tst_res TPASS "cpu${cpu_num} is offline."
    else
        tst_res TFAIL "cpu${cpu_num} is online."
        ((ret++))
    fi

    cpu_num_isolated_state=$(cat $global_state | grep 'Isolated:'  \
    | sed -n "${cpu_number}p" | awk -F ':' '{print$2}')
    if [ $cpu_num_isolated_state -eq 0 ]; then
        tst_res TPASS "cpu${cpu_num} isolated state was cleaned."
    else
        tst_res TFAIL "cpu${cpu_num} isolated state was not cleaned."
        ((ret++))
    fi
}

check_movement()
{
    cpu_pid=0
    for pid in $(cat taskpid.txt); do
        if [ $(sed -n '/^cpu#${cpu_num}/,/cpu#${cpu_number}$/p' $proc_sd  \
        | awk -F " " '{print $3}' | grep -w "$pid") ];then
            cpu_pid=$(($cpu_pid + 1))
        fi
    done

    if [ $cpu_pid -eq 0 ]; then
        tst_res TPASS "cpu$cpu_num process migrated."
    else
        tst_res TFAIL "cpu$cpu_num process is not migrated."
        ((ret++))
    fi
}

isolated_cpu_online()
{
    echo 1 > /sys/devices/system/cpu/cpu${cpu_num}/online
    cpu_online_state1=$(cat $global_state | grep 'Online:'  \
    | sed -n "${cpu_number}p" | awk -F ':' '{print$2}')
    if [ ${cpu_online_state1} -eq 1 ];then
        tst_res TPASS "cpu${cpu_num} is online."
    else
        tst_res TFAIL "cpu${cpu_num} is offline."
        ((ret++))
    fi

    cpu_num_isolated_state1=$(cat $global_state | grep 'Isolated:'  \
    | sed -n "${cpu_number}p" | awk -F ':' '{print$2}')
    if [ $cpu_num_isolated_state1 -eq 0 ]; then
        tst_res TPASS "cpu${cpu_num} is active."
    else
        tst_res TFAIL "cpu${cpu_num} is isolated."
        ((ret++))
    fi

    for i in $(cat active_cpu1.txt); do
        line1=$(( $i + 1))
        cpu_isolated_state1=$(cat $global_state | grep 'Isolated:'  \
        | sed -n "${line1}p" | awk -F ':' '{print$2}')
        if [ $cpu_isolated_state1 -eq 1 ]; then
            isolated_num1=$(( $isolated_num1 + 1 ))
        fi
    done

    if [ ${isolated_num1} -eq 1 ];then
        tst_res TPASS "A active cpu is isolated."
    else
        tst_res TFAIL "the cpus state error."
        ((ret++))
    fi
}

active_cpu_online()
{
    active_num2=0
    isolated_num2=0
    for i in $(seq 0 3); do
        line2=$(( $i + 1))
        cpu_isolated_state2=$(cat $global_state | grep 'Isolated:'  \
        | sed -n "${line2}p" | awk -F ':' '{print$2}')
        if [ $cpu_isolated_state2 -eq 0 ]; then
            tst_res TINFO "cpu$i is active."
            active_num2=$(( $active_num2 + 1 ))
            echo $active_num2
            echo $i >> active_cpu2.txt
        fi

        if [ $cpu_isolated_state2 -eq 1 ]; then
            tst_res TINFO "cpu$i is isolated."
            isolated_num2=$(( $isolated_num2 + 1 ))
            echo $isolated_num2
            echo $i >> isolated_cpu2.txt
        fi
    done
    if [[ $active_num2 -eq 2 ]] && [[ $isolated_num2 -eq 2 ]];then
        tst_res TPASS "two cpus is active,and two cpus is isolated."
    else
        tst_res TFAIL "the cpus state error."
        ((ret++))
    fi
    cpu_num1=$(cat active_cpu2.txt | sed -n "1p" )

    echo 0 > /sys/devices/system/cpu/cpu${cpu_num1}/online
    cpu_number1=$(( $cpu_num1 + 1 ))
    cpu_online_state2=$(cat $global_state | grep 'Online:'  \
    | sed -n "${cpu_number1}p" | awk -F ':' '{print$2}')
    if [ ${cpu_online_state2} -eq 0 ];then
        tst_res TPASS "cpu${cpu_num1} is offline."
    else
        tst_res TFAIL "cpu${cpu_num1} is online."
        ((ret++))
    fi

    echo 1 > /sys/devices/system/cpu/cpu${cpu_num1}/online
    cpu_online_state3=$(cat $global_state | grep 'Online:'  \
    | sed -n "${cpu_number1}p" | awk -F ':' '{print$2}')
    if [ ${cpu_online_state3} -eq 1 ];then
        tst_res TPASS "cpu${cpu_num1} is online."
    else
        tst_res TFAIL "cpu${cpu_num1} is offline."
        ((ret++))
    fi

    for i in $(cat isolated_cpu2.txt); do
        line3=$(( $i + 1 ))
        cpu_num_isolated_state2=$(cat $global_state | grep 'Isolated:'  \
        | sed -n "${line3}p" | awk -F ':' '{print$2}')
        isolated_num3=$(( $isolated_num3 + 1 ))
    done
    if [ $isolated_num3 -eq 2 ]; then
        tst_res TPASS "isolated number does not change."
    else
        tst_res TFAIL "isolated number had been changed."
    fi
}

do_clean()
{
    ps -ef | grep "create_process" | grep -v "grep" | cut -c 9-18  \
    | xargs kill -9
    echo "y" | rm isolated_cpu1.txt
    echo "y" | rm active_cpu1.txt
    echo "y" | rm isolated_cpu2.txt
    echo "y" | rm active_cpu2.txt
}

do_setup
do_test
do_clean
tst_exit
