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
# File: cpusetdecouple_cpuhotplug02.sh
#
# Description: Check whether process are migrated when the CPU is offline
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

	tst_res TINFO "Start test cupset_decouple_cpuhotplug02"
	mkdir /dev/cpuset/hotplug02
	echo "1" > /dev/cpuset/hotplug02/cpuset.cpus
	cat /dev/cpuset/hotplug02/cpuset.cpus

	sh cpuhotplug_do_spin_loop > /dev/null 2>&1 &
	pid=$!

	echo $pid > /dev/cpuset/hotplug02/cgroup.procs
	echo 0 > /sys/devices/system/cpu/cpu1/online

	cat /dev/cpuset/hotplug02/cpuset.cpus
	cpu_set=$(cat /dev/cpuset/hotplug02/cpuset.cpus)

	if [ "$cpu_set" == '1' ]; then
		tst_res TINFO "hotplug02 cpu1 offline cpuset decouple success"
	else
		tst_res TINFO "hotplug02 cpu1 offline cpuset decouple fail"
		ret=$(( $ret + 1 ))
	fi

	if [ $ret -eq 0 ];then
		tst_res TPASS "process are migrated when the CPU is offline pass."
	else
		tst_res TFAIL "process are migrated when the CPU is offline failed!"
	fi

	echo 1 > /sys/devices/system/cpu/cpu1/online

}

do_clean()
{
	rmdir /dev/cpuset/hotplug02
	killall cpuhotplug_do_spin_loop
}

do_setup
do_test
do_clean
tst_exit
