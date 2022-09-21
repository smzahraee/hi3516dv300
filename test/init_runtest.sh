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
# File: init_runtest.sh
#
# Description: init for linuxkerneltest runtest
#
# Authors:     Ma Feng - mafeng.ma@huawei.com
#
# History:     Mar 15 2022 - init scripts
#
################################################################################

cp -r $1/ $2

cd $2

tar -zcvf runtest.tar.gz runtest

cd -
