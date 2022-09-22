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
# File: run_fio.sh
#
# Description: run the fio
#
# Authors:     Li Zhanming - lizhanming3@h-partners.com
#
# History:     April 8 2022 - init scripts
#
################################################################################

run_fio()
{
    ./fio --name=rw_bg --numjobs=1 --filename=/mnt/f2fs_mount/fio-test.file  \
     --bs=32768K --rw=read --ioengine=psync --refill_buffers --group_reporting  \
     --runtime=360 --time_based --filesize=128M     
}

run_fio