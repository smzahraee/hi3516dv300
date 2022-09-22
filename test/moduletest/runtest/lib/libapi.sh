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
# File: libapi.sh
#
# Description: shell library api for linuxkerneltest
#
# Authors:     Ma Feng - mafeng.ma@huawei.com
#
# History:     Mar 15 2022 - init scripts
#
################################################################################

print_error()
{
    echo -e "\033[41m$1\033[0m"
}

print_warn()
{
    echo -e "\033[43m$1\033[0m"
}

print_pass()
{
    echo -e "\033[42m$1\033[0m"
}

print_info()
{
    echo -e "\033[37m$1\033[0m"
}

print_deg()
{
    if [ $DEBUG -eq 1 ]; then
        echo -e "\033[1;33m$1\033[0m"
    fi
}
