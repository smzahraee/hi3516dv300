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
# File: tracepoint.sh
#
# Description: test tracepoint
#
# Authors:     yang ming di
#
# History:     August 4 2022 - test tracepoint
#
################################################################################

CURRENT_DIR=$(pwd)
ROOT_DIR=$(cd $CURRENT_DIR/../../ && pwd)
ROOT_FILE_DIR=$ROOT_DIR/kernel/linux/build/test/tracepointtest
#ROOT_TEST_DIR=$(cd $CURRENT_DIR/../../../../../ && pwd)
COMPILE_DIR=$ROOT_DIR/out/kernel/src_tmp/linux-5.10
OBJ_DIR=$ROOT_DIR/out/kernel/OBJ
DRIVERS_DIR=${ROOT_DIR}/out/kernel/src_tmp/linux-5.10/drivers
TRACEPOINT_INCLUDE_DIR=${ROOT_DIR}/out/kernel/src_tmp/linux-5.10/include/trace/hooks
DRIVERS_TRACEPOINT_DIR=${ROOT_DIR}/out/kernel/src_tmp/linux-5.10/drivers/tracepointtest
CONFIG_DIR=${ROOT_DIR}/out/kernel/src_tmp/linux-5.10/arch/arm64/configs

copy() {
  echo "copy $1 to $2"
  cp -rf $1 $2
}

modify_config() {
  if [ -e $CONFIG_DIR/tmp ]; then
    rm -f $CONFIG_DIR/tmp
  fi

  cp -f $CONFIG_DIR/$2 $CONFIG_DIR/$2_tmpfile

  while read line; do
    echo "$line" >>$CONFIG_DIR/tmp
  done <$CONFIG_DIR/$2

  while read line; do
    if [[ "$line" != "#"* ]]; then
      echo "$line" >>$CONFIG_DIR/tmp
    fi
  done <$1

  mv $CONFIG_DIR/tmp $CONFIG_DIR/$2
}

modify_files() {
  KCONFIG=$DRIVERS_DIR/Kconfig
  MAKEFILE=$DRIVERS_DIR/Makefile
  VENDOR_HOOKS=$DRIVERS_DIR/hooks/vendor_hooks.c
  TMPFILE=$DRIVERS_DIR/tmp

  cp -f $KCONFIG ${KCONFIG}_tmpfile
  cp -f $MAKEFILE ${MAKEFILE}_tmpfile
  cp -f $VENDOR_HOOKS ${VENDOR_HOOKS}_tmpfile

  if [ -e $TMPFILE ]; then
    rm -f $TMPFILE
  fi

  while read line; do
    if [[ "$line" != "endmenu" ]]; then
      echo "$line" >>$TMPFILE
    fi
  done <$KCONFIG
  echo "source \"drivers/tracepointtest/Kconfig\"" >>$TMPFILE
  echo "endmenu" >>$TMPFILE
  mv $TMPFILE $KCONFIG

  while read line; do
    echo "$line" >>$TMPFILE
  done <$MAKEFILE
  echo "obj-y   += tracepointtest/" >>$TMPFILE
  mv $TMPFILE $MAKEFILE

  while read line; do
    echo "$line" >>$TMPFILE
  done <$VENDOR_HOOKS
  echo "#include <trace/hooks/emmc.h>" >>$TMPFILE
  echo "EXPORT_TRACEPOINT_SYMBOL_GPL(vendor_aml_emmc_partition);" >>$TMPFILE
  echo "EXPORT_TRACEPOINT_SYMBOL_GPL(vendor_fake_boot_partition);" >>$TMPFILE
  mv $TMPFILE $VENDOR_HOOKS
}

compile() {
  cd $COMPILE_DIR || exit
  export PRODUCT_COMPANY=hihope
  export DEVICE_NAME=rk3568
  export DEVICE_COMPANY=rockchip
  export PRODUCT_PATH=~/OpenHarmony/master/out/kernel/vendor/hihope/rk3568
  ./make-ohos.sh TB-RK3568X0 >null
  if [ $? -ne 0 ]; then
    echo "compile failed"
    exit 1
  else
    echo "compile success"
  fi
}

collectKO() {
  if [ -e $OBJ_DIR/kofiles ]; then
    rm -f $OBJ_DIR/kofiles
    mkdir -p $OBJ_DIR/kofiles
  else
    mkdir -p $OBJ_DIR/kofiles
  fi

  find $DRIVERS_TRACEPOINT_DIR -name '*.ko' | xargs cp -t $OBJ_DIR/kofiles
}

restore() {
  CONFIGNAME=rockchip_linux_defconfig
  KCONFIG=$DRIVERS_DIR/Kconfig
  MAKEFILE=$DRIVERS_DIR/Makefile
  VENDOR_HOOKS=$DRIVERS_DIR/hooks/vendor_hooks.c

  rm -rf $DRIVERS_TRACEPOINT_DIR
  mv -f $CONFIG_DIR/${CONFIGNAME}_tmpfile $CONFIG_DIR/$CONFIGNAME
  mv -f ${KCONFIG}_tmpfile $KCONFIG
  mv -f ${MAKEFILE}_tmpfile $MAKEFILE
  mv -f ${VENDOR_HOOKS}_tmpfile $VENDOR_HOOKS
  rm -rf $COMPILE_DIR/.lock
}

main() {
  if [ -e $COMPILE_DIR/.lock ]; then
    restore
  fi

  echo "" >$COMPILE_DIR/.lock

  if [ -d $DRIVERS_DIR/tracepointtest ]; then
    rm -rf $DRIVERS_DIR/tracepointtest
    mkdir -p $DRIVERS_DIR/tracepointtest
  else
    mkdir -p $DRIVERS_DIR/tracepointtest
  fi

  for dir in $(ls $ROOT_FILE_DIR); do
    if [ -d $ROOT_FILE_DIR/$dir ]; then
      copy $ROOT_FILE_DIR/$dir $DRIVERS_TRACEPOINT_DIR/$dir
    elif [[ "$dir" == "Makefile" ]]; then
      copy $ROOT_FILE_DIR/$dir $DRIVERS_TRACEPOINT_DIR/$dir
    elif [[ "$dir" == "Kconfig" ]]; then
      copy $ROOT_FILE_DIR/$dir $DRIVERS_TRACEPOINT_DIR/$dir
    elif [[ $dir == *.h ]]; then
      copy $ROOT_FILE_DIR/$dir $TRACEPOINT_INCLUDE_DIR/$dir
    elif [[ "$dir" == "rockchip_linux_defconfig" ]]; then
      modify_config $ROOT_FILE_DIR/$dir $dir
    fi
  done

  modify_files
  compile
  collectKO
  restore
}

main
