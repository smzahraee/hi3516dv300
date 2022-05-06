#!/bin/sh
################################################################################
#
# Copyright (C) 2022 Huawei Device Co., Ltd.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
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