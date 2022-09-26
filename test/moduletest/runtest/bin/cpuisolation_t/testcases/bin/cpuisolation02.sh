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
# File: cpuisolation02.sh
#
# Description: check CPU lightweight isolation basic function
#
# Authors:     liudanning - liudanning@h-partners.com
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
    ret=0
    dir_name=/sys/devices/system/cpu/cpu0/core_ctl
    global_state=${dir_name}/global_state
    proc_sd=/proc/sched_debug
    cpu_total=$(cat /proc/cpuinfo | grep "processor"| wc -l)
    cpu_total=$(( $cpu_total - 1 ))

    for i in $(seq 0 $cpu_total); do
        touch cpu${i}_taskpid.txt
    done

    tst_res TINFO "Start to check CPU lightweight isolation basic function."
    sh create_process.sh 40
    sleep 20

    echo "y" | rm cpu_log.txt
    sleep 1
    cat $proc_sd > cpu_log.txt
    cpu_num0=0
    cpu_num1=0
    cpu_num2=0
    cpu_num3=0
    # check sh distributed on each CPU
    for pid in $(cat taskpid.txt); do
        echo $pid
        if [ $(sed -n '/^cpu#0/,/cpu#1$/p' cpu_log.txt | awk -F " " '{print $3}'  \
        | awk '!arr[$0]++' | grep -w "$pid") ]; then
            cpu_num0=$(($cpu_num0 + 1))
            echo $pid >> cpu0_taskpid.txt
        elif [ $(sed -n '/^cpu#1/,/cpu#2$/p' cpu_log.txt | awk -F " " '{print $3}'  \
        | awk '!arr[$0]++' | grep -w "$pid") ]; then
            cpu_num1=$(($cpu_num1 + 1))
            echo $pid >> cpu1_taskpid.txt
        elif [ $(sed -n '/^cpu#2/,/cpu#3$/p' cpu_log.txt | awk -F " " '{print $3}'  \
        | awk '!arr[$0]++' | grep -w "$pid") ]; then
            cpu_num2=$(($cpu_num2 + 1))
            echo $pid >> cpu2_taskpid.txt
        elif [ $(sed -n '/^cpu#3/,$p' cpu_log.txt | awk -F " " '{print $3}'  \
        | awk '!arr[$0]++' | grep -w "$pid") ]; then
            cpu_num3=$(($cpu_num3 + 1))
            echo $pid >> cpu3_taskpid.txt
        fi
    done

    echo 2 > /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
    sleep 5
    # both CPUs' isolated is set to 1 and NR isolated is set to 2
    count=0
    cpu_total=$(cat /proc/cpuinfo | grep "processor"| wc -l)
    cpu_total=$(( $cpu_total -1 ))
    for i in $(seq 0 $cpu_total); do
        line=$(( $i + 1 ))
        cpu_isolated=$(cat $global_state | grep 'Isolated:'  \
        | sed -n "${line}p" | awk -F ':' '{print$2}')
        nr_isolated=$(cat $global_state | grep 'Nr isolated CPUs:'  \
        | sed -n "${line}p" | awk -F ':' '{print$2}')
        if [[ $cpu_isolated -eq 1 && $nr_isolated -eq 2 ]]; then
            tst_res TINFO "cpu$i Isolated: 1,and Nr isolated CPUs: 2."
            count=$(( $count + 1 ))
            check_migration
        fi
    done

    if [ $count -eq 2 ]; then
        tst_res TPASS "two Isolated set to 1,and two Nr isolated CPUs set to 2."
    else
        tst_res TFAIL "Isolated not set to 1 ,or Nr isolated CPUs not set to 2."
        ((ret++))
    fi
    echo "ret=$ret"
    if [ $ret -eq 0 ]; then
        tst_res TPASS "CPU lightweight isolation basic function test success."
    else
        tst_res TFAIL "CPU lightweight isolation basic function test failed!"
    fi

    echo 4 > /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
}

check_migration()
{
    res_3_pid=0
    res_012_pid=0
    # when the isolation CPU is 0/1/2, check the migration
    if [[ $i -eq 0 || $i -eq 1 || $i -eq 2 ]];then
        cpu_taskpid=cpu${i}_taskpid.txt
        echo "cputaskpid$i:::::::"
        cat cpu${i}_taskpid.txt
        for pid1 in $(cat $cpu_taskpid); do
            i_cpu=$(( $i + 1 ))
            sed -n '/^cpu#$i/,/cpu#${i_cpu}$/p' $proc_sd  \
            | awk -F " " '{print $3}' | grep -w "$pid1"
            res_012_pid=$(($res_012_pid + $?))
        done
        echo "cpu$i: $res_012_pid"
        if [ $res_012_pid -eq $(eval echo '$'cpu_num"$i") ];then
            tst_res TPASS "cpu$i process migrated."
        else
            tst_res TFAIL "cpu$i process is not migrated."
            ((ret++))
        fi
        res_012_pid=0
        # when the isolation CPU is 3, check the migration
    else
        cat cpu3_taskpid.txt
        for pid2 in $(cat cpu3_taskpid.txt); do
            tail -n+$(sed -n -e "/cpu#3/=" $proc_sd) $proc_sd \
            | awk -F " " '{print $3}' | grep -w "$pid2"
            res_3_pid=$(($res_3_pid + $?))
        done
        if [ $res_3_pid -eq $cpu_num3 ];then
            tst_res TPASS "cpu3 process migrated."
        else
            tst_res TFAIL "cpu3 process is not migrated."
            ((ret++))
        fi
    fi
}

do_clean()
{
    ps -ef | grep "create_process" | grep -v "grep" | cut -c 9-18  \
    | xargs kill -9
    echo "y" | rm cpu0_taskpid.txt
    echo "y" | rm cpu1_taskpid.txt
    echo "y" | rm cpu2_taskpid.txt
    echo "y" | rm cpu3_taskpid.txt
}

do_setup
do_test
do_clean
tst_exit