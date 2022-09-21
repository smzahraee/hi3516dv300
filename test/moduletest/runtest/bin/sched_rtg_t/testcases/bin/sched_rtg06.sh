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
# File: sched_rtg06.sh
#
# Description: sched RTG Stability test
#
# Authors:     liudanning - liudanning@h-partners.com
#
# History:     April 6 2022 - init scripts
#
################################################################################

source tst_oh.sh

do_setup()
{
    dmesg -c
    PPID=$(ps -ef | grep "/sched_rtg06.sh"  | grep -v grep | awk '{print $3}')
}

do_test()
{
    stability_test randmom

    stability_test ordered

    stability_test all
}

stability_test()
{
    sh create_process.sh 40
    if [ "$1" == "randmom" ]; then
        tst_res TINFO "All 40 porcesss join random rtg from 2 to 20"
        random_rtg
    fi

    if [ "$1" == "ordered" ]; then
        tst_res TINFO "All 40 processes join rtg from 2 to 20 one by one"
        ordered_rtg
    fi

    if [ "$1" == "all" ]; then
        tst_res TINFO "All 40 processes join rtg 2"
        all_in_one_rtg
    fi
    sleep 60
    tst_res TINFO "kill 40 loop processes...."
    ps -ef | grep "sched_rtg06.sh" | grep -v "grep" | grep -v ${PPID} | cut -c 9-18 | xargs kill -9
    tst_res TINFO "kill 40 task processes...."
    ps -ef | grep "create_process" | grep -v "grep" | grep -v ${PPID} | cut -c 9-18 | xargs kill -9
    sleep 5
    tst_res TINFO "kill process successed."
    aa start -b ohos.samples.ecg -a ohos.samples.ecg.MainAbility &&
    sleep 1 &&
    PID=$(ps -ef | grep ohos.samples.ecg | grep -v grep | awk '{print $2}')
    if [ $? -eq 0 ]; then
        dmesg | grep "BUG" ||
        dmesg | grep "panic" ||
        dmesg | grep "Unable to handle kernel" ||
        dmesg | grep "WARNING:"
        if [ $? -eq 0 ]; then
            tst_res TFAIL "$1 test error messages found!"
        else
            tst_res TPASS "sched RTG Stability $1 test success."
        fi
    else
        tst_res TFAIL "sched RTG Stability  $1 test failed!"
    fi
    aa force-stop ohos.samples.ecg
}



random_rtg()
{
    for i in $(seq 1 40); do
    {
        while true; do
            echo $((RANDOM % 19 + 2)) > /proc/$(sed -n ${i}p taskpid.txt)/sched_group_id
            sleep 0.1
            echo 0 > /proc/$(sed -n ${i}p taskpid.txt)/sched_group_id
            sleep 0.2
        done
    }&
    done
}

ordered_rtg()
{
    for i in $(seq 1 40); do
    {
        if [ ${i} -le 20 ]; then
            while true; do
                echo ${i} > /proc/$(sed -n ${i}p taskpid.txt)/sched_group_id
                sleep 0.1
                echo 0 > /proc/$(sed -n ${i}p taskpid.txt)/sched_group_id
                sleep 0.2
            done &
        else
            while true; do
                echo 2 > /proc/$(sed -n ${i}p taskpid.txt)/sched_group_id
                sleep 0.1
                echo 0 > /proc/$(sed -n ${i}p taskpid.txt)/sched_group_id
                sleep 0.2
            done
        fi
    }&
    done
}

all_in_one_rtg()
{
    local _rtg_id=$((RANDOM % 19 + 2))
    for i in $(seq 1 40); do
    {
        while true; do
            echo $_rtg_id > /proc/$(sed -n ${i}p taskpid.txt)/sched_group_id
            sleep 0.1
            echo 0 > /proc/$(sed -n ${i}p taskpid.txt)/sched_group_id
            sleep 0.2
        done
    }&
    done
}

do_clean()
{
    rm -rf taskpid.txt
}

do_setup
do_test
do_clean
tst_exit