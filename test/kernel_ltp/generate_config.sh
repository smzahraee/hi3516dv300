#!/bin/bash
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
# File: generate_config.sh
#
# Description: generate config for linux test project
#
# Authors:     Wu Fan
#
# History:     August 4 2022 - generate config
#
################################################################################
set -e
IFS=$'\n'
input_file=$2/macrolists
change_file=$3/ltp/include/config.h

function chang_config()
{
    while read line; do
        if [[ "${line}" == *"#"* ]]; then
            continue
        else
            macro=$(echo $line | awk -F "'" '{print $2}')
            flag=$(echo $line | awk -F "'" '{print $4}')
	    set +e
            if [ "${flag}" == "true" ]; then
                lines=$(sed -n "/${macro}/=" $change_file)
                if [[ "${lines}" > 0 ]]; then
                    sed -i "/${macro}/c\#define ${macro} 1" $change_file
                else
                    echo "#define ${macro} 1" >> $change_file
                fi
            else
                sed -i "/${macro}/c\/\* \#undef ${macro} \*\/" $change_file
            fi
            set -e
        fi
    done < $input_file
    echo "typedef unsigned int __u32;" >> $change_file
    echo "typedef signed int __s32;" >> $change_file
}

mkdir -p $(pwd)/tests/ltp_testcases/ltp
cp -r $(pwd)/../../third_party/ltp $(pwd)/tests/ltp_testcases
cd $(pwd)/tests/ltp_testcases/ltp
make autotools
./configure --without-numa
add_notation=./include/tst_clone.h
sed -i "/^\#define clone/c\/\/ \#define clone(...) (use_the_ltp_clone_functions__do_not_use_clone)" $add_notation
chang_config
