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
# File: tracepointtestko.sh
#
# Description: tracepoint ko test
#
# Authors:     yang ming di
#
# History:     August 4 2022 - tracepoint ko test
#
################################################################################

set -e

CURRENT_DIR=$(pwd)
KO_DIR=${CURRENT_DIR}/kofile

insmod_ko() {
  for file in $(ls ${KO_DIR}); do
    if [[ "${file}" != "tracepoint_test.ko" ]]; then
      insmod ${KO_DIR}/${file}
      echo "${KO_DIR}/${file} is loaded"
    fi
  done

  if [ -e "${KO_DIR}/tracepoint_test.ko" ]; then
    insmod ${KO_DIR}/tracepoint_test.ko
  else
    echo "no such file tracepoint_test.ko"
    exit 1
  fi

  arr=(vendor_do_mmap vendor_do_mprotect_pkey vendor_aml_emmc_partition vendor_fake_boot_partition)
  set +e
  for i in ${arr[@]}; do
    dmesg | grep $i >/dev/null
    if [ $? -eq 0 ]; then
      echo "tracepoint $i succeed"
    else
      echo "tracepoint $i failed"
    fi
  done
  set -e
}

rmmod_ko() {
  for dir in $(ls ${KO_DIR}); do
      rmmod ${KO_DIR}/${dir}
      echo "${KO_DIR}/${dir} is removed"
  done
}

main() {
  if [[ "$1" == "rmmod_ko" ]]; then
    rmmod_ko
  else
    insmod_ko
  fi
}

main $1
