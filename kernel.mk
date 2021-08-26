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
#
# ohos makefile to build kernel

PRODUCT_NAME=$(TARGET_PRODUCT)
OHOS_BUILD_HOME := $(realpath $(shell pwd)/../../../)
KERNEL_SRC_TMP_PATH := $(OUT_DIR)/kernel/${KERNEL_VERSION}
ifeq ($(BUILD_TYPE), standard)
    OHOS_BUILD_HOME := $(OHOS_ROOT_PATH)
    BOOT_IMAGE_PATH = $(OHOS_BUILD_HOME)/device/hisilicon/hispark_taurus/prebuilts
    KERNEL_SRC_TMP_PATH := $(OUT_DIR)/kernel/src_tmp/${KERNEL_VERSION}
endif

KERNEL_SRC_PATH := $(OHOS_BUILD_HOME)/kernel/${KERNEL_VERSION}
KERNEL_PATCH_PATH := $(OHOS_BUILD_HOME)/kernel/linux/patches/${KERNEL_VERSION}
KERNEL_CONFIG_PATH := $(OHOS_BUILD_HOME)/kernel/linux/config/${KERNEL_VERSION}
PREBUILTS_GCC_DIR := $(OHOS_BUILD_HOME)/prebuilts/gcc
CLANG_HOST_TOOLCHAIN := $(OHOS_BUILD_HOME)/prebuilts/clang/ohos/linux-x86_64/llvm/bin
KERNEL_HOSTCC := $(CLANG_HOST_TOOLCHAIN)/clang
KERNEL_PREBUILT_MAKE := make

ifeq ($(BUILD_TYPE), standard)
    KERNEL_ARCH := arm
    KERNEL_TARGET_TOOLCHAIN := $(PREBUILTS_GCC_DIR)/linux-x86/arm/gcc-linaro-7.5.0-arm-linux-gnueabi/bin
    KERNEL_TARGET_TOOLCHAIN_PREFIX := $(KERNEL_TARGET_TOOLCHAIN)/arm-linux-gnueabi-
    CLANG_CC := $(CLANG_HOST_TOOLCHAIN)/clang
else ifeq ($(BUILD_TYPE), small)
    KERNEL_ARCH := arm
    ifeq ($(CLANG_CC), "")
        CLANG_CC := $(CLANG_HOST_TOOLCHAIN)/clang
    endif
endif

KERNEL_PERL := /usr/bin/perl

KERNEL_CROSS_COMPILE :=
KERNEL_CROSS_COMPILE += CC="$(CLANG_CC)"
ifeq ($(BUILD_TYPE), standard)
    KERNEL_CROSS_COMPILE += HOSTCC="$(KERNEL_HOSTCC)"
    KERNEL_CROSS_COMPILE += PERL=$(KERNEL_PERL)
    KERNEL_CROSS_COMPILE += CROSS_COMPILE="$(KERNEL_TARGET_TOOLCHAIN_PREFIX)"
else ifeq ($(BUILD_TYPE), small)
    KERNEL_CROSS_COMPILE += CROSS_COMPILE="arm-linux-gnueabi-"
endif

KERNEL_MAKE := \
    PATH="$(BOOT_IMAGE_PATH):$$PATH" \
    $(KERNEL_PREBUILT_MAKE)


ifneq ($(findstring $(BUILD_TYPE), small standard),)
DEVICE_PATCH_DIR := $(OHOS_BUILD_HOME)/kernel/linux/patches/${KERNEL_VERSION}/$(DEVICE_NAME)_patch
DEVICE_PATCH_FILE := $(DEVICE_PATCH_DIR)/$(DEVICE_NAME).patch
HDF_PATCH_FILE := $(DEVICE_PATCH_DIR)/hdf.patch
KERNEL_IMAGE_FILE := $(KERNEL_SRC_TMP_PATH)/arch/arm/boot/uImage
DEFCONFIG_FILE := $(DEVICE_NAME)_$(BUILD_TYPE)_defconfig
export HDF_PROJECT_ROOT=$(OHOS_BUILD_HOME)/

$(KERNEL_IMAGE_FILE):
	$(hide) echo "build kernel..."
	$(hide) rm -rf $(KERNEL_SRC_TMP_PATH);mkdir -p $(KERNEL_SRC_TMP_PATH);cp -arfL $(KERNEL_SRC_PATH)/* $(KERNEL_SRC_TMP_PATH)/
	$(hide) cd $(KERNEL_SRC_TMP_PATH) && patch -p1 < $(HDF_PATCH_FILE) && patch -p1 < $(DEVICE_PATCH_FILE)
	$(hide) cp -rf $(KERNEL_CONFIG_PATH)/. $(KERNEL_SRC_TMP_PATH)/
	$(hide) $(KERNEL_MAKE) -C $(KERNEL_SRC_TMP_PATH) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) distclean
	$(hide) $(KERNEL_MAKE) -C $(KERNEL_SRC_TMP_PATH) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) $(DEFCONFIG_FILE)
	$(hide) $(KERNEL_MAKE) -C $(KERNEL_SRC_TMP_PATH) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) -j64 uImage
endif
.PHONY: build-kernel
build-kernel: $(KERNEL_IMAGE_FILE)
