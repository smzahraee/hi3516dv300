#!/bin/sh
################################################################################
#
# Copyright (C) 2022 Huawei Device Co., Ltd.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
# File: cpuisolation04.sh
#
# Description: check CPU lightweight isolation stress test
#
# Authors:     liudanning - liudanning@h-partners.com
#
# History:     Mar 24 2022 - init scripts
#
################################################################################

source tst_oh.sh

do_setup()
{
    mkdir /data/local/pid_tmp
    mkdir /data/local/cpuisolation
    PPID=$(ps -ef | grep "/cpuisolation04.sh"  | grep -v grep | awk '{print $3}')
}

do_test()
{
    ret=0
    dir_name=/sys/devices/system/cpu/cpu0/core_ctl
    global_state=${dir_name}/global_state
    tst_res TINFO "Start to check CPU lightweight isolation stress test"
    isolated_cpu1=/data/local/cpuisolation/isolated_cpu1.txt
    active_cpu1=/data/local/cpuisolation/active_cpu1.txt
    active_num1=0
    isolated_num1=0
    proc_sd=/proc/sched_debug
    cpu_log=/data/local/pid_tmp/cpu_log

    sh create_process.sh 40
    sleep 5
    for i in $(seq 0 5); do
        randmom=$((RANDOM %4 + 1))
        echo $randmom > /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
        do_isolate
        if [ $randmom -ne 4 ]; then
            do_num
        fi
        sleep 2
    done
    tst_res TINFO "kill 40 task processes...."
    ps -ef | grep "create_process" | grep -v "grep"  \
    | grep -v ${PPID} | cut -c 9-18 | xargs kill -9
    echo "check stress test"
    echo "ret=$ret"
    if [ $ret -eq 0 ]; then
        tst_res TPASS "CPU lightweight isolation stress test success."
    else
        tst_res TFAIL "CPU lightweight isolation stress test failed!"
    fi

    echo 4 > /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
}

do_isolate()
{
    touch /data/local/cpuisolation/isolated_cpu1.txt
    touch /data/local/cpuisolation/active_cpu1.txt
    for i in $(seq 0 3); do
        line=$(( $i + 1))
        cpu_isolated_state=$(cat $global_state | grep 'Isolated:'  \
        | sed -n "${line}p" | awk -F ':' '{print$2}')
        if [ $cpu_isolated_state -eq 0 ]; then
            tst_res TINFO "cpu$i is active."
            active_num=$(( $active_num + 1 ))
            echo $i >> $active_cpu1
        else
            tst_res TINFO "cpu$i is isolated."
            isolated_num=$(( $isolated_num + 1 ))
            echo $i >> $isolated_cpu1
        fi
    done

    if [ $active_num -eq $randmom ];then
        tst_res TPASS "isolation is right."
    else
        tst_res TFAIL "the cpus state error."
        ret=$(( $ret + 1 ))
    fi
    active_num=0
    isolated_num=0
}

do_num()
{
    cpu_pid0=0
    cpu_pid1=0
    cpu_pid2=0
    cpu_pid3=0
    rm -rf $cpu_log
    cat $proc_sd > $cpu_log
    for i in $(cat $isolated_cpu1); do
        for pid in $(cat taskpid.txt); do
        if [ $(sed -n '/^cpu#0/,/cpu#1$/p' $cpu_log  \
        | awk -F " " '{print $3}' | grep -w "$pid") ];then
            cpu_pid0=$(($cpu_pid0 + 1))
        elif [ $(sed -n '/^cpu#1/,/cpu#2$/p' $cpu_log  \
        | awk -F " " '{print $3}' | grep -w "$pid") ];then
            cpu_pid1=$(($cpu_pid1 + 1))
        elif [ $(sed -n '/^cpu#2/,/cpu#3$/p' $cpu_log  \
        | awk -F " " '{print $3}' | grep -w "$pid") ];then
            cpu_pid2=$(($cpu_pid2 + 1))
        elif [ $(sed -n '/^cpu#3/,$p' $cpu_log  \
        | awk -F " " '{print $3}' | grep -w "$pid") ];then
            cpu_pid3=$(($cpu_pid3 + 1))
        fi
        done
        if [ $(eval echo '$'cpu_pid"$i") -eq 0 ]; then
            tst_res TPASS "cpu${i} process migrated."
        else
            tst_res TFAIL "cpu${i} process is not migrated."
            ret=$(( $ret + 1 ))
        fi
    done
    
    rm -rf /data/local/cpuisolation/isolated_cpu1.txt
    rm -rf /data/local/cpuisolation/active_cpu1.txt
}

do_clean()
{
    rm -rf /data/local/pid_tmp
    rm -rf /data/local/cpuisolation
    rm -rf /data/local/pid_tmp/cpu_log
}

do_setup
do_test
do_clean
tst_exit