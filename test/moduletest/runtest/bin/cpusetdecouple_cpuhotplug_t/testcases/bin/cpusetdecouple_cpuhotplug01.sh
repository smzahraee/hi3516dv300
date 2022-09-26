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
# File: cpusetdecouple_cpuhotplug01.sh
#
# Description: Check whether CPU hot-plug and CPUSET decoupling are implemented
#
# Authors:     Ma Feng - mafeng.ma@huawei.com
#
# History:     Mar 15 2022 - init scripts
#
################################################################################
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

	tst_res TINFO "Start test cupsetdecouple_cpuhotplug01"
	mkdir /dev/cpuset/hotplug01
	echo "0-3" > /dev/cpuset/hotplug01/cpuset.cpus
	cat /dev/cpuset/hotplug01/cpuset.cpus

	cpu_total=$(cat /proc/cpuinfo | grep "processor" | wc -l)
	cpu_total=$(( $cpu_total -1 ))

	for i in $(seq 1 $cpu_total); do
		echo $i
		echo 0 > /sys/devices/system/cpu/cpu$i/online
		cat /dev/cpuset/hotplug01/cpuset.cpus
		cpu_set=$(cat /dev/cpuset/hotplug01/cpuset.cpus)
		if [ "$cpu_set" == '0-3' ]; then
			tst_res TINFO "hotplug01 cpu$i offline cpuset decouple success"
		else
			tst_res TINFO "hotplug01 cpu$i offline cpuset decouple fail"
			ret=$(( $ret + 1 ))
		fi
		echo 1 > /sys/devices/system/cpu/cpu$i/online
	done

	if [ $ret -eq 0 ];then
		tst_res TPASS "CPU hot-plug and CPUSET decoupling are implemented pass."
	else
		tst_res TFAIL "CPU hot-plug and CPUSET decoupling are implemented failed!"
	fi
}

do_clean()
{
	rmdir /dev/cpuset/hotplug01
}

do_setup
do_test
do_clean
tst_exit
