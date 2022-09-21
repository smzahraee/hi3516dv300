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
# File: enhancedf2fs01.sh
#
# Description: enhancedf2fs_t testsuite init script
#
# Authors:     Li Zhanming - lizhanming3@h-partners.com
#
# History:     April 8 2022 - init scripts
#
################################################################################
export IMG_FILE=/data/image_f2fs

create_catalogue()
{
    mkdir /mnt/f2fs_mount/
}

enable_init()
{
    dd if=/dev/zero of=$IMG_FILE bs=1M count=20480
}

echo "***************************ENHANCED INIT START***************************"
create_catalogue
enable_init
echo "***************************ENHANCED INIT END*****************************"
