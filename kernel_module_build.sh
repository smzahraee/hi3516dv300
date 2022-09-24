#!/bin/bash
# Copyright (c) 2021 Huawei Device Co., Ltd.
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

set -e

export OUT_DIR=$1
export BUILD_TYPE=$2
export KERNEL_ARCH=$3
export PRODUCT_PATH=$4
export DEVICE_NAME=$5
export KERNEL_VERSION=$6
if [ "$BUILD_TYPE" == "small" ];then
    LINUX_KERNEL_OUT=${OUT_DIR}/kernel/${KERNEL_VERSION}
elif [ "$BUILD_TYPE" == "standard" ];then
    LINUX_KERNEL_OUT=${OUT_DIR}/kernel/src_tmp/${KERNEL_VERSION}
fi
LINUX_KERNEL_OBJ_OUT=${OUT_DIR}/kernel/OBJ/${KERNEL_VERSION}

export OHOS_ROOT_PATH=$(pwd)/../../..
# it needs adaptation for more device target
kernel_image=""
if [ "$KERNEL_ARCH" == "arm" ];then
    kernel_image="uImage"
elif [ "$KERNEL_ARCH" == "arm64" ];then
    kernel_image="Image"
elif [ "$KERNEL_ARCH" == "x86_64" ];then
    kernel_image="bzImage"
fi
export KERNEL_IMAGE=${kernel_image}
LINUX_KERNEL_IMAGE_FILE=${LINUX_KERNEL_OBJ_OUT}/arch/${KERNEL_ARCH}/boot/${kernel_image}

if [ "$DEVICE_NAME" == "hispark_phoenix"  ];then
export SDK_SOURCE_DIR=${OHOS_ROOT_PATH}/device/soc/hisilicon/hi3751v350/sdk_linux/source
fi

make -f kernel.mk

if [ -f "${LINUX_KERNEL_IMAGE_FILE}" ];then
    echo "Image: ${LINUX_KERNEL_IMAGE_FILE} build success"
else
    echo "Image: ${LINUX_KERNEL_IMAGE_FILE} build failed!!!"
    exit 1
fi

if [ "$5" == "hispark_taurus" ];then
    cp -rf ${LINUX_KERNEL_IMAGE_FILE} ${OUT_DIR}/uImage_${DEVICE_NAME}_smp
fi

exit 0
