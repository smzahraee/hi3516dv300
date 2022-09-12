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
KERNEL_OBJ_TMP_PATH := $(OUT_DIR)/kernel/OBJ/${KERNEL_VERSION}
ifeq ($(BUILD_TYPE), standard)
    BOOT_IMAGE_PATH = $(OHOS_BUILD_HOME)/device/board/hisilicon/hispark_taurus/uboot/prebuilts
    KERNEL_SRC_TMP_PATH := $(OUT_DIR)/kernel/src_tmp/${KERNEL_VERSION}
    export KERNEL_SRC_DIR=out/KERNEL_OBJ/kernel/src_tmp/${KERNEL_VERSION}
endif

KERNEL_SRC_PATH := $(OHOS_BUILD_HOME)/kernel/linux/${KERNEL_VERSION}
KERNEL_PATCH_PATH := $(OHOS_BUILD_HOME)/kernel/linux/patches/${KERNEL_VERSION}
KERNEL_CONFIG_PATH := $(OHOS_BUILD_HOME)/kernel/linux/config/${KERNEL_VERSION}
PREBUILTS_GCC_DIR := $(OHOS_BUILD_HOME)/prebuilts/gcc
CLANG_HOST_TOOLCHAIN := $(OHOS_BUILD_HOME)/prebuilts/clang/ohos/linux-x86_64/llvm/bin
KERNEL_HOSTCC := $(CLANG_HOST_TOOLCHAIN)/clang
KERNEL_PREBUILT_MAKE := make
CLANG_CC := $(CLANG_HOST_TOOLCHAIN)/clang

ifeq ($(KERNEL_ARCH), arm)
    KERNEL_TARGET_TOOLCHAIN := $(PREBUILTS_GCC_DIR)/linux-x86/arm/gcc-linaro-7.5.0-arm-linux-gnueabi/bin
    KERNEL_TARGET_TOOLCHAIN_PREFIX := $(KERNEL_TARGET_TOOLCHAIN)/arm-linux-gnueabi-
else ifeq ($(KERNEL_ARCH), arm64)
    KERNEL_TARGET_TOOLCHAIN := $(PREBUILTS_GCC_DIR)/linux-x86/aarch64/gcc-linaro-7.5.0-2019.12-x86_64_aarch64-linux-gnu/bin
    KERNEL_TARGET_TOOLCHAIN_PREFIX := $(KERNEL_TARGET_TOOLCHAIN)/aarch64-linux-gnu-
else ifeq ($(KERNEL_ARCH), x86_64)
    KERNEL_TARGET_TOOLCHAIN := gcc
    KERNEL_TARGET_TOOLCHAIN_PREFIX :=
endif

KERNEL_CROSS_COMPILE :=
ifeq ($(DEVICE_NAME), hispark_phoenix)
KERNEL_CROSS_COMPILE += CONFIG_MSP="y"
endif

KERNEL_CROSS_COMPILE += CC="$(CLANG_CC)"

ifneq ($(KERNEL_ARCH), x86_64)
KERNEL_CROSS_COMPILE += CROSS_COMPILE="$(KERNEL_TARGET_TOOLCHAIN_PREFIX)"
endif

KERNEL_MAKE := \
    PATH="$(BOOT_IMAGE_PATH):$$PATH" \
    $(KERNEL_PREBUILT_MAKE)


ifneq ($(findstring $(BUILD_TYPE), small standard),)
DEVICE_PATCH_DIR := $(OHOS_BUILD_HOME)/kernel/linux/patches/${KERNEL_VERSION}/$(DEVICE_NAME)_patch
DEVICE_PATCH_FILE := $(DEVICE_PATCH_DIR)/$(DEVICE_NAME).patch
PRODUCT_PATCH_FILE := $(OHOS_BUILD_HOME)/vendor/hisilicon/watchos/patches/$(DEVICE_NAME).patch
SMALL_PATCH_FILE := $(DEVICE_PATCH_DIR)/$(DEVICE_NAME)_$(BUILD_TYPE).patch
KERNEL_IMAGE_FILE := $(KERNEL_SRC_TMP_PATH)/arch/$(KERNEL_ARCH)/boot/$(KERNEL_IMAGE)
DEFCONFIG_FILE := $(DEVICE_NAME)_$(BUILD_TYPE)_defconfig
NEWIP_PATCH_FILE := $(OHOS_BUILD_HOME)/foundation/communication/sfc/newip/apply_newip.sh

export KBUILD_OUTPUT=$(KERNEL_OBJ_TMP_PATH)

$(KERNEL_IMAGE_FILE):
	$(hide) echo "build kernel..."
ifeq ($(DEVICE_NAME), hispark_phoenix)
	$(hide) rm -rf $(KERNEL_SRC_TMP_PATH);mkdir -p $(KERNEL_SRC_TMP_PATH);cp -arfP $(KERNEL_SRC_PATH)/* $(KERNEL_SRC_TMP_PATH)/
	$(hide) cd $(KERNEL_SRC_TMP_PATH)/drivers && rm -rf common && ln -s $(SDK_SOURCE_DIR)/common/drv ./common && cd -
	$(hide) cd $(KERNEL_SRC_TMP_PATH)/drivers && rm -rf msp && ln -s $(SDK_SOURCE_DIR)/msp/drv ./msp && cd -
else
	$(hide) rm -rf $(KERNEL_SRC_TMP_PATH);mkdir -p $(KERNEL_SRC_TMP_PATH);cp -arfL $(KERNEL_SRC_PATH)/* $(KERNEL_SRC_TMP_PATH)/
endif
	$(hide) $(OHOS_BUILD_HOME)/drivers/hdf_core/adapter/khdf/linux/patch_hdf.sh $(OHOS_BUILD_HOME) $(KERNEL_SRC_TMP_PATH) $(KERNEL_PATCH_PATH) $(DEVICE_NAME)
     
ifeq ($(PRODUCT_PATH), vendor/hisilicon/watchos)
	$(hide) cd $(KERNEL_SRC_TMP_PATH) && patch -p1 < $(PRODUCT_PATCH_FILE)
else
	$(hide) cd $(KERNEL_SRC_TMP_PATH) && patch -p1 < $(DEVICE_PATCH_FILE)
endif 

ifneq ($(findstring $(BUILD_TYPE), small),)
	$(hide) cd $(KERNEL_SRC_TMP_PATH) && patch -p1 < $(SMALL_PATCH_FILE)
endif

ifeq ($(NEWIP_PATCH_FILE), $(wildcard $(NEWIP_PATCH_FILE)))
	$(hide) $(NEWIP_PATCH_FILE) $(OHOS_BUILD_HOME) $(KERNEL_SRC_TMP_PATH) $(DEVICE_NAME) ${KERNEL_VERSION}
endif
	$(hide) cp -rf $(KERNEL_CONFIG_PATH)/. $(KERNEL_SRC_TMP_PATH)/
	$(hide) $(KERNEL_MAKE) -C $(KERNEL_SRC_TMP_PATH) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) distclean
	$(hide) $(KERNEL_MAKE) -C $(KERNEL_SRC_TMP_PATH) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) $(DEFCONFIG_FILE)
ifeq ($(KERNEL_VERSION), linux-5.10)
	$(hide) $(KERNEL_MAKE) -C $(KERNEL_SRC_TMP_PATH) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) modules_prepare
endif
	$(hide) $(KERNEL_MAKE) -C $(KERNEL_SRC_TMP_PATH) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) -j64 $(KERNEL_IMAGE)
endif
ifeq ($(DEVICE_NAME), hispark_phoenix)
	$(hide) $(KERNEL_MAKE) -C $(KERNEL_SRC_TMP_PATH) ARCH=$(KERNEL_ARCH) $(KERNEL_CROSS_COMPILE) dtbs
endif
.PHONY: build-kernel
build-kernel: $(KERNEL_IMAGE_FILE)
