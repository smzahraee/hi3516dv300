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
# File: enhancedf2fs01.sh
#
# Description: enhancedf2fs_t testsuite init script
#
# Authors:     Li Zhanming - lizhanming3@h-partners.com
#
# History:     April 8 2022 - init scripts
#
################################################################################

create_catalogue()
{
    export DISK_PATH=$(mount | grep f2fs | cut -F 3)
    export DISK_NAME=$(df -h |grep /dev/block |grep $DISK_PATH |awk '{print $1}' |cut -d "/" -f4)
}

test_remount()
{
	gc_merge_mount_opt=$(mount |grep gc_merge)
	if [[ "$gc_merge_mount_opt" == "" ]] ;then
		mount -o remount,gc_merge $DISK_PATH/
		mount -o remount,nogc_merge $DISK_PATH/
	else
		mount -o remount,nogc_merge $DISK_PATH/
		mount -o remount,gc_merge $DISK_PATH/
	fi
	mount -o remount,rw $DISK_PATH/
}

enable_init()
{

}

echo "***************************ENHANCED INIT START***************************"
create_catalogue
test_remount
enable_init
echo "***************************ENHANCED INIT END*****************************"
