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
# File: cpusetdecouple_cpuhotplug03.sh
#
# Description: Check whether processes will be migrated to new online CPU
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

	tst_res TINFO "Start test cupset_decouple_cpuhotplug03"
	mkdir /dev/cpuset/hotplug03
	echo 0 > /sys/devices/system/cpu/cpu2/online
	echo 0 > /sys/devices/system/cpu/cpu3/online

	echo "0-3" > /dev/cpuset/hotplug03/cpuset.cpus
	cat /dev/cpuset/hotplug03/cpuset.cpus
	cpu_set=$(cat /dev/cpuset/hotplug03/cpuset.cpus)
	if [ "$cpu_set" == '0-3' ]; then
		tst_res TINFO "hotplug03 cpu2 cpu3 offline cpuset decouple success"
	else
		tst_res TINFO "hotplug03 cpu2 cpu3 offline cpuset decouple fail"
		ret=$(( $ret + 1 ))
	fi

	if [ $ret -eq 0 ]; then
		tst_res TPASS "processes will be migrated to new online CPU pass."
	else
		tst_res TFAIL "processes will be migrated to new online CPU failed!"
	fi

	for i in $(seq 1 100); do
		sh cpuhotplug_do_spin_loop > /dev/null 2>&1 &
		pid=$!
		echo $pid > /dev/cpuset/hotplug03/cgroup.procs
	done

	echo 1 > /sys/devices/system/cpu/cpu2/online
	echo 1 > /sys/devices/system/cpu/cpu3/online

}

do_clean()
{
	rmdir /dev/cpuset/hotplug03
	killall cpuhotplug_do_spin_loop
}

do_setup
do_test
do_clean
tst_exit
