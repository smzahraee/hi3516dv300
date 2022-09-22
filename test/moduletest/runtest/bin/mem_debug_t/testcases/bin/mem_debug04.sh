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
# File: mem_debug04.sh
#
# Description:  Meminfo's dimension measurement information extension test
#
# Authors:     Wangyuting - wangyuting36@huawei.com
#
# History:     Mar 20 2022 - init scripts
#
################################################################################
source tst_oh.sh

do_setup()
{
    zcat /proc/config.gz | grep CONFIG_PAGE_TRACING=y || tst_res TCONF "ONFIG_PAGE_TRACING=y not satisfied!"

    avail_buffers=/dev/memcg/memory.avail_buffers

    local zswapd_s=/dev/memcg/memory.zswapd_pressure_show
    local buffer_size=$(cat $zswapd_s | grep 'buffer_size' | awk -F ':' '{print$2}')

    avail_buffers_def=$(cat /dev/memcg/memory.avail_buffers | awk '$1=="avail_buffers:"{print $2}')
    min_avail_buffers_def=$(cat /dev/memcg/memory.avail_buffers | awk '$1=="min_avail_buffers:"{print $2}')
    high_avail_buffers_def=$(cat /dev/memcg/memory.avail_buffers | awk '$1=="high_avail_buffers:"{print $2}')
    free_swap_threshold_def=$(cat /dev/memcg/memory.avail_buffers | awk '$1=="free_swap_threshold:"{print $2}')

    echo 0 $(( $buffer_size + 50 )) $(( $buffer_size + 100 )) 0 > $avail_buffers
    sleep 3
}

do_test()
{
    local ret=0

    sh ../../../mem_debug_t_uninit.sh
    local old_vmallocused=$(cat /proc/meminfo | awk '$1=="VmallocUsed:"{print $2}')
    local old_zspageused=$(cat /proc/meminfo | awk '$1=="ZspageUsed:"{print $2}')
    local old_gltrack=$(cat /proc/meminfo | awk '$1=="GLTrack:"{print $2}')

    sh ../../../mem_debug_t_init.sh
    aa start -b com.ohos.settings -a com.ohos.settings.MainAbility
    aa start -b ohos.samples.airquality -a ohos.samples.airquality.default
    aa start -b ohos.samples.ecg -a ohos.samples.ecg.MainAbility
    aa start -b ohos.samples.flashlight -a ohos.samples.flashlight.default
    aa start -b ohos.samples.clock -a ohos.samples.clock.default

    local new_vmallocused=$(cat /proc/meminfo | awk '$1=="VmallocUsed:"{print $2}')
    local new_zspageused=$(cat /proc/meminfo | awk '$1=="ZspageUsed:"{print $2}')
    local new_gltrack=$(cat /proc/meminfo | awk '$1=="GLTrack:"{print $2}')

    if [ "$old_gltrack" == "-" ] && [ "$new_gltrack" == "-" ]; then
        tst_res TPASS "Gltrack equals '-'"
    else
        tst_res TFAIL "Gltrack not equals '-'"
        ret=$(($ret + 1))
    fi

    local res_vmallocused=$(($new_vmallocused - $old_vmallocused))
    local res_zspageused=$(($new_zspageused - $old_zspageused))

    if [ $res_vmallocused -le 0 ]; then
        tst_res TFAIL "Vmallocused not growing"
        ret=$(($ret + 1))
    fi
    if [ $res_zspageused -le 0 ]; then
        tst_res TFAIL "ZspageUsed not growing"
        ret=$(($ret + 1))
    fi

    if [ $ret -eq 0 ]; then
        tst_res TPASS "Meminfo's dimension measurement information extension test pass."
    else
        tst_res TFAIL "Meminfo's dimension measurement information extension test failed!"
    fi
}

do_clean()
{
    echo $avail_buffers_def $min_avail_buffers_def $high_avail_buffers_def $free_swap_threshold_def > $avail_buffers
}

do_setup
do_test
do_clean
tst_exit