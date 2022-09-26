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
# File: sched_rtg01.sh
#
# Description: sched RTG /proc/$PID/sched_group_id basic function test
#
# Authors:     Ma Feng - mafeng.ma@huawei.com
#
# History:     April 6 2022 - init scripts
#
################################################################################

source tst_oh.sh

do_setup()
{
    sh create_process.sh 1
    sleep 1
    PID=$(ps -ef | grep "create_process" | grep -v grep | awk '{print $2}')
}

do_test()
{
    local res=0
    local sched_group_id=/proc/$PID/sched_group_id

    tst_res TINFO "Start process $PID join rtgid 2 test ..."
    cur_rtgid=$(cat $sched_group_id)
    if [ cur_rtgid -eq 2 ]; then
        tst_res TINFO "process $PID already in rtgid 2, remove it firstly..."
        echo 0 > $sched_group_id
    fi

    echo 2 > $sched_group_id
    if [ $? -ne 0 ]; then
        tst_res TFAIL "echo 2 > $sched_group_id failed!"
        res=$(($res + 1))
    fi
    local rtgid2=$(cat $sched_group_id)
    if [ $rtgid2 -ne 2 ]; then
        tst_res TFAIL "process $PID join rtgid 2 failed!"
        res=$(($res + 1))
    fi

    tst_res TINFO "Start process $PID switch rtgid 2 to 3 test ..."
    echo 3 > $sched_group_id
    if [ $? -eq 0 ]; then
        tst_res TFAIL "echo 3 > $sched_group_id success unexpected."
        res=$(($res + 1))
    fi
    local rtgid3=$(cat $sched_group_id)
    if [ $rtgid3 -eq 3 ]; then
        tst_res TFAIL "process $PID switch rtgid 2 to 3 sucess unexpected!"
        res=$(($res + 1))
    fi

    tst_res TINFO "Start process $PID remove rtgid 2 test ..."
    echo 0 > $sched_group_id
    if [ $? -ne 0 ]; then
        tst_res TFAIL "process $PID remove rtgid 2 failed!"
        res=$(($res + 1))
    fi
    local rtgid0=$(cat $sched_group_id)
    if [ $rtgid0 -ne 0 ]; then
        tst_res TINFO "process $PID remove rtgid 2 failed!"
        res=$(($res + 1))
    fi

    if [ $res -eq 0 ]; then
        tst_res TPASS "sched RTG /proc/$PID/sched_group_id basic function pass."
    else
        tst_res TFAIL "sched RTG /proc/$PID/sched_group_id basic function failed!"
    fi
}

do_clean()
{
    ps -ef | grep "create_process" | grep -v "grep" | cut -c 9-18  \
    | xargs kill -9
}

do_setup
do_test
do_clean
tst_exit