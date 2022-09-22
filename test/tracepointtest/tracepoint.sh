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
# File: tracepoint.sh
#
# Description: test tracepoint
#
# Authors:     yang ming di
#
# History:     August 4 2022 - test tracepoint
#
################################################################################

set -e

CURRENT_DIR=$(pwd)
ROOT_DIR=$(cd ${CURRENT_DIR}/../../ && pwd)
ROOT_FILE_DIR=${ROOT_DIR}/kernel/linux/build/test/tracepointtest
COMPILE_DIR=${ROOT_DIR}/out/kernel/src_tmp/linux-5.10
OBJ_DIR=${ROOT_DIR}/out/kernel/OBJ
DRIVERS_DIR=${ROOT_DIR}/out/kernel/src_tmp/linux-5.10/drivers
TRACEPOINT_INCLUDE_DIR=${ROOT_DIR}/out/kernel/src_tmp/linux-5.10/include/trace/hooks
DRIVERS_TRACEPOINT_DIR=${ROOT_DIR}/out/kernel/src_tmp/linux-5.10/drivers/tracepointtest
CONFIG_DIR=${ROOT_DIR}/out/kernel/src_tmp/linux-5.10/arch/arm64/configs

copy() {
  local SOURCE_PATH=$1
  local TARGET_PATH=$2
  echo "copy ${SOURCE_PATH} to ${TARGET_PATH}"
  cp -rf ${SOURCE_PATH} ${TARGET_PATH}
}

modify_config() {
  local SOURCE_FILE=$1
  local TARGET_FILE=$2
  if [ -e "${CONFIG_DIR}/tmp" ]; then
    rm -f ${CONFIG_DIR}/tmp
  fi

  cp -f ${CONFIG_DIR}/${TARGET_FILE} ${CONFIG_DIR}/${TARGET_FILE}_tmpfile

  while read line; do
    echo "$line" >>${CONFIG_DIR}/tmp
  done <${CONFIG_DIR}/${TARGET_FILE}

  while read line; do
    if [[ "$line" != "#"* ]]; then
      echo "$line" >>${CONFIG_DIR}/tmp
    fi
  done <${SOURCE_FILE}

  mv ${CONFIG_DIR}/tmp ${CONFIG_DIR}/${TARGET_FILE}
}

modify_files() {
  local KCONFIG=${DRIVERS_DIR}/Kconfig
  local MAKEFILE=${DRIVERS_DIR}/Makefile
  local VENDOR_HOOKS=${DRIVERS_DIR}/hooks/vendor_hooks.c
  local TMPFILE=${DRIVERS_DIR}/tmp

  cp -f ${KCONFIG} ${KCONFIG}_tmpfile
  cp -f ${MAKEFILE} ${MAKEFILE}_tmpfile
  cp -f ${VENDOR_HOOKS} ${VENDOR_HOOKS}_tmpfile

  if [ -e "${TMPFILE}" ]; then
    rm -f ${TMPFILE}
  fi

  while read line; do
    if [[ "$line" != "endmenu" ]]; then
      echo "$line" >>${TMPFILE}
    fi
  done <${KCONFIG}
  echo "source \"drivers/tracepointtest/Kconfig\"" >>${TMPFILE}
  echo "endmenu" >>${TMPFILE}
  mv ${TMPFILE} ${KCONFIG}

  while read line; do
    echo "$line" >>${TMPFILE}
  done <${MAKEFILE}
  echo "obj-y   += tracepointtest/" >>${TMPFILE}
  mv ${TMPFILE} ${MAKEFILE}

  while read line; do
    echo "$line" >>${TMPFILE}
  done <${VENDOR_HOOKS}
  echo "#include <trace/hooks/emmc.h>" >>${TMPFILE}
  echo "EXPORT_TRACEPOINT_SYMBOL_GPL(vendor_aml_emmc_partition);" >>${TMPFILE}
  echo "EXPORT_TRACEPOINT_SYMBOL_GPL(vendor_fake_boot_partition);" >>${TMPFILE}
  mv ${TMPFILE} ${VENDOR_HOOKS}
}

compile() {
  cd ${COMPILE_DIR} || exit
  export PRODUCT_COMPANY=hihope
  export DEVICE_NAME=rk3568
  export DEVICE_COMPANY=rockchip
  export PRODUCT_PATH=${ROOT_DIR}/out/kernel/vendor/hihope/rk3568
  ./make-ohos.sh TB-RK3568X0 >null
  if [ $? -ne 0 ]; then
    echo "compile failed"
    exit 1
  else
    echo "compile success"
  fi
}

collect_ko() {
  if [ -e "${OBJ_DIR}/kofiles" ]; then
    rm -f ${OBJ_DIR}/kofiles
    mkdir -p ${OBJ_DIR}/kofiles
  else
    mkdir -p ${OBJ_DIR}/kofiles
  fi

  find ${DRIVERS_TRACEPOINT_DIR} -name '*.ko' | xargs cp -t ${OBJ_DIR}/kofiles
}

restore() {
  local CONFIGNAME=rockchip_linux_defconfig
  local KCONFIG=${DRIVERS_DIR}/Kconfig
  local MAKEFILE=${DRIVERS_DIR}/Makefile
  local HEADERFILE=${TRACEPOINT_INCLUDE_DIR}/emmc.h
  local VENDOR_HOOKS=${DRIVERS_DIR}/hooks/vendor_hooks.c

  if [ -d "${DRIVERS_TRACEPOINT_DIR}" ]; then
    rm -rf ${DRIVERS_TRACEPOINT_DIR}
  fi

  if [ -e "${HEADERFILE}" ]; then
    rm -rf ${HEADERFILE}
  fi
  mv -f ${CONFIG_DIR}/${CONFIGNAME}_tmpfile ${CONFIG_DIR}/${CONFIGNAME}
  mv -f ${KCONFIG}_tmpfile ${KCONFIG}
  mv -f ${MAKEFILE}_tmpfile ${MAKEFILE}
  mv -f ${VENDOR_HOOKS}_tmpfile ${VENDOR_HOOKS}
  if [ -e "${COMPILE_DIR}/.lock" ]; then
    rm -rf ${COMPILE_DIR}/.lock
  fi
}

main() {
  if [ -e "${COMPILE_DIR}/.lock" ]; then
    restore
  fi

  echo "" >${COMPILE_DIR}/.lock

  if [ -d "${DRIVERS_DIR}/tracepointtest" ]; then
    rm -rf ${DRIVERS_DIR}/tracepointtest
    mkdir -p ${DRIVERS_DIR}/tracepointtest
  else
    mkdir -p ${DRIVERS_DIR}/tracepointtest
  fi

  for dir in $(ls "${ROOT_FILE_DIR}"); do
    if [ -d "${ROOT_FILE_DIR}/${dir}" ]; then
      copy ${ROOT_FILE_DIR}/${dir} ${DRIVERS_TRACEPOINT_DIR}/${dir}
    elif [[ "${dir}" == "Makefile" ]]; then
      copy ${ROOT_FILE_DIR}/${dir} ${DRIVERS_TRACEPOINT_DIR}/${dir}
    elif [[ "${dir}" == "Kconfig" ]]; then
      copy ${ROOT_FILE_DIR}/${dir} ${DRIVERS_TRACEPOINT_DIR}/${dir}
    elif [[ "${dir}" == *.h ]]; then
      copy ${ROOT_FILE_DIR}/${dir} ${TRACEPOINT_INCLUDE_DIR}/${dir}
    elif [[ "${dir}" == "rockchip_linux_defconfig" ]]; then
      modify_config ${ROOT_FILE_DIR}/${dir} ${dir}
    fi
  done

  modify_files
  compile
  collect_ko
  restore
}

main
