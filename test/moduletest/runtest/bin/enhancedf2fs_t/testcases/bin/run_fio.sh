#!/bin/sh
################################################################################
#
# Copyright (C) 2022 Huawei Device Co., Ltd.
# SPDX-License-Identifier: GPL-2.0
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
    mkdir $DISK_PATH/f2fs_test
    ./fio --name=rw_bg --numjobs=1 --filename=$DISK_PATH/f2fs_test/fio-test.file  \
    --bs=32768K --rw=read --ioengine=sync --refill_buffers --group_reporting  \
    --runtime=360 --time_based --filesize=128M
}

run_fio