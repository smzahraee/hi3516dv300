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
# File: create_processs.sh
#
# Description: create process
#
# Authors:     liudanning - liudanning@h-partners.com
#
# History:     Mar 24 2022 - init scripts
#
################################################################################

rm -rf taskpid.txt
num=$1
for i in $(seq 1 $num); do
    #echo "start $i proc ..."
    while true; do
        ((cnt++))
        sleep 0.1
    done &
    local pgid=$!
    #echo "pid ${i}  $pgid generated"
    echo $pgid >> taskpid.txt
done