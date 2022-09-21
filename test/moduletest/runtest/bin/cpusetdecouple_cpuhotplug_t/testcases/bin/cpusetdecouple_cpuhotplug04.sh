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
# File: cpusetdecouple_cpuhotplug04.sh
#
# Description: Test CPU online and offline function
#
# Authors:     Ma Feng - mafeng.ma@huawei.com
#
# History:     Mar 15 2022 - init scripts
#
#################################################################################
source tst_oh.sh

do_setup()
{
	if [ ! -d "/dev/cpuset" ]; then
		mkdir /dev/cupset
	fi

	if mountpoint -q /dev/cpuset; then
		tst_res TINFO "mountpoint -q /dev/cpuset"
	else
		mount -t cpuset none /dev/cupset
		tst_res TINFO "mount -t cpuset none /dev/cupset"
	fi
}

do_test()
{
	local ret=0

	tst_res TINFO "Start test cupset_decouple_cpuhotplug04"
	mkdir /dev/cpuset/hotplug04
	echo "0-3" > /dev/cpuset/hotplug04/cpuset.cpus
	cat /dev/cpuset/hotplug04/cpuset.cpus

	cpu_total=$(cat /proc/cpuinfo | grep "processor" | wc -l)
	cpu_total=$(( $cpu_total -1 ))

	for i in $(seq 0 $cpu_total); do
		echo $i
		echo 0 > /sys/devices/system/cpu/cpu$i/online
		cat /dev/cpuset/hotplug04/cpuset.cpus
		cpu_set=$(cat /dev/cpuset/hotplug04/cpuset.cpus)
		if [ "$cpu_set" == '0-3' ]; then
			tst_res TINFO "hotplug04 cpu$i offline cpuset decouple success"
		else
			tst_res TINFO "hotplug04 cpu$i offline cpuset decouple fail"
			ret=$(( $ret + 1 ))
		fi
	done

	if [ $ret -eq 0 ]; then
		tst_res TPASS "CPU online and offline function pass."
	else
		tst_res TFAIL "CPU online and offline function failed!"
	fi

	for i in $(seq 0 $cpu_total); do
		echo 1 > /sys/devices/system/cpu/cpu$i/online
	done
}

do_clean()
{
	rmdir /dev/cpuset/hotplug04
}

do_setup
do_test
do_clean
tst_exit
