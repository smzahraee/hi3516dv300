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
    mkdir /mnt/f2fs_mount/
}

enable_init()
{
    dd if=/dev/zero of=/data/image_f2fs bs=1M count=20480
}

echo "***************************ENHANCED INIT START***************************"
create_catalogue
enable_init
echo "***************************ENHANCED INIT END*****************************"
