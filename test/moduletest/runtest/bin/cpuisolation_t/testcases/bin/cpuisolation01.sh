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
# File: cpuisolation01.sh
#
# Description: check rw nodes test about CPU lightweight isolation
#
# Authors:     liudanning - liudanning@h-partners.com
#
# History:     Mar 24 2022 - init scripts
#
################################################################################

source tst_oh.sh

do_setup()
{
    echo 0 > /sys/devices/system/cpu/cpu0/core_ctl/min_cpus
    echo 4 > /sys/devices/system/cpu/cpu0/core_ctl/max_cpus
}

write_invalid()
{
    local max_value=$1
    local min_value=$2
    local mode=$3

    min_cpus_value=$(cat $min_cpus)
    max_cpus_value=$(cat $max_cpus)
    min_cpus_value_backup=$(cat $min_cpus)
    max_cpus_value_backup=$(cat $max_cpus)

    echo $max_value > $max_cpus
    ret_max=$?
    echo $min_value > $min_cpus
    ret_min=$?
    min_cpus_value=$(cat $min_cpus)
    max_cpus_value=$(cat $max_cpus)

    # mode 1 is to inject a single invalid value
    if [ $mode -eq 1 ]; then
        if [ $ret_min -eq 1 ]; then
            check_value
        elif [ $min_cpus_value -eq 4 ]; then
            check_value
        elif [ $ret_max -eq 1 ]; then
            check_value
        elif [[ $min_cpus_value -eq 0 ]] && [[ $max_cpus_value -eq 4 ]]; then
            check_value
        else
            tst_res TFAIL "writing single MAX VALUE $max_value or  \
            MIN VALUE $min_value failed."
            ((ret++))
        fi
    fi
    
    # mode 2 is to inject both invalid values
    if [ $mode -eq 2 ]; then
        if [[ $ret_min -eq 1 ]] && [[ $ret_max -eq 1 ]]; then
            check_value
        elif [[ $ret_min -eq 1 ]] && [[ $max_cpus_value -eq 4 ]]; then
            check_value
        elif [[ $ret_max -eq 1 ]] && [[ $min_cpus_value -eq 4 ]]; then
            check_value
        elif [[ $ret_max -ne 1 ]] && [[ $max_cpus_value -eq 4 ]] &&  \
        [[ $min_cpus_value -eq 4 ]]; then
            check_value
        else
            tst_res TFAIL "writing both MAX VALUE $max_value and  \
            MIN VALUE $min_value failed."
            ((ret++))
        fi
    fi

    echo ${min_cpus_value_backup} > $min_cpus
    echo ${max_cpus_value_backup} > $max_cpus
}

check_value()
{
    if [ $min_cpus_value -ge 0 ] && [ $min_cpus_value -le $max_cpus_value ]\
           && [ $max_cpus_value -le 4 ]; then
        tst_res TPASS "writing MAX VALUE $max_value and MIN VALUE $min_value , \
        value is normal."
    else
        tst_res TFAIL "writing MAX VALUE $max_value and MIN VALUE $min_value , \
        value is abnormal."
        ((ret++))
    fi
}

do_test()
{
    local ret=0
    local dir_name=/sys/devices/system/cpu/cpu0/core_ctl
    local min_cpus=${dir_name}/min_cpus
    local max_cpus=${dir_name}/max_cpus

    active_cpus=${dir_name}/active_cpus
    enable=${dir_name}/enable
    global_state=${dir_name}/global_state
    need_cpus=${dir_name}/need_cpus

    tst_res TINFO "Start to check rw nodes test about CPU lightweight isolation."
    if [[ -e "${active_cpus}" && -e "${enable}" && -e "${global_state}" \
          && -e "${max_cpus}" && -e "${min_cpus}" && -e "${need_cpus}" ]]; then
        tst_res TPASS "/sys/devices/system/cpu/cpu0/core_ctl/ node normal."
    else
        tst_res TFAIL "/sys/devices/system/cpu/cpu0/core_ctl/ node abnormal."
        ((ret++))
    fi

    write_invalid 4 -3 1
    write_invalid 4 999 1
    write_invalid -3 0 1
    write_invalid 999 0 1
    write_invalid -3 -3 2
    write_invalid 999 -3 2
    write_invalid -3 999 2
    write_invalid 999 999 2

    cpu_total=$(cat /proc/cpuinfo | grep "processor"| wc -l)
    cpu_total=$(( $cpu_total - 1 ))
    for i in $(seq 0 $cpu_total); do
        cpu_name=$(cat $global_state | grep "CPU${i}")
        echo $cpu_name
        if [ "$cpu_name"x = "CPU${i}"x ]; then
            tst_res TPASS "cpu$i name correct."
        else
            tst_res TFAIL "cpu$i name incorrect."
            ((ret++))
        fi

        line=$(( $i + 1))
        cpu_online_state=$(cat $global_state | grep 'Online:' | \
                         sed -n "${line}p" | awk -F ':' '{print$2}')
        if [ $cpu_online_state -eq 1 ]; then
            tst_res TPASS "cpu$i online."
        else
            tst_res TFAIL"cpu$i offline."
            ((ret++))
        fi

        cpu_isolated_state=$(cat $global_state | grep 'Isolated:' | \
                           sed -n "${line}p" | awk -F ':' '{print$2}')
        if [ $cpu_isolated_state -eq 0 ]; then
            tst_res TPASS "cpu$i isolated : 0."
        else
            tst_res TFAIL "cpu$i isolated : 1."
            ((ret++))
        fi

        cpu_is_busy_state=$(cat $global_state | grep 'Is busy:' | \
                          sed -n "${line}p" | awk -F ':' '{print$2}')
        if [ $cpu_is_busy_state -eq 1 ]; then
            tst_res TPASS "cpu$i is_busy : 1."
        else
            tst_res TFAIL "cpu$i is_busy : 0."
            ((ret++))
        fi
    done

    if [ $ret -eq 0 ];then
        tst_res TPASS "check rw nodes test about CPU isolation successfully."
        exit 0
    else
        tst_res TFAIL "check rw nodes test about CPU isolation failed!"
        exit 1
    fi
}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit