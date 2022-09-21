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
# File: mem_debug03.sh
#
# Description:  Dmabuf usage of process query test
#
# Authors:     Wangyuting - wangyuting36@huawei.com
#
# History:     Mar 20 2022 - init scripts
#
################################################################################
source tst_oh.sh

do_setup()
{
    zcat /proc/config.gz | grep CONFIG_DMABUF_PROCESS_INFO=y ||  \
    tst_res TCONF "CONFIG_DMABUF_PROCESS_INFO=y not satisfied!"
}

do_test()
{
    local result=$(cat /proc/process_dmabuf_info | grep Process | grep pid  \
    | grep fd | grep size_bytes | grep ino | grep exp_pid | grep exp_task_comm  \
    | grep buf_name | grep exp_name)

    if [ "$result" == "" ]; then
        tst_res TFAIL "Dmabuf usage of process query test failed!"
    else
        tst_res TPASS "Dmabuf usage of process query test pass."
    fi
}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit