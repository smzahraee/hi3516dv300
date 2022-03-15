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
# File: cpusetdecouple_cpuhotplug02.sh
#
# Description: Check whether process are migrated when the CPU is offline
#
# Authors:     Ma Feng - mafeng.ma@huawei.com
#
# History:     Mar 15 2022 - init scripts
#
################################################################################

ret=0

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

	if [ $cpu_set == '1' ]; then
		tst_res TINFO "hotplug02 cpu1 offline cpuset decouple success"
	else
		tst_res TINFO "hotplug02 cpu1 offline cpuset decouple fail"
		ret=$(( $ret + 1 ))
	fi

	if [ $ret -eq 0 ];then
		tst_res TPASS "cpusetdecouple_cpuhotplug02 CPU hot-plug and CPUSET decoupling are implemented."
	else
		tst_res TFAIL "cpusetdecouple_cpuhotplug02 CPU hot-plug and CPUSET decoupling are implemented."
	fi

	echo 1 > /sys/devices/system/cpu/cpu1/online #offline cpu$i

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
