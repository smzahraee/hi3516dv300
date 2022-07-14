# Patch组件<a name="ZH-CN_TOPIC_0000001078264110"></a>

-   [简介](#section11660541593)
-   [特定芯片架构驱动补丁（比如Hi3516DV300）](#section1521510717399)
-   [目录](#section21571344112)
-   [使用说明](#section1393789267)
-   [构建说明](#section19369206113115)
-   [相关仓](#section27639463106)

## 简介<a name="section11660541593"></a>

OpenHarmony的Linux内核基于开源Linux内核LTS **4.19.y / 5.10.y** 分支演进，在此基线基础上，回合CVE补丁及OpenHarmony特性，作为OpenHarmony Common Kernel基线。针对不同的芯片，各厂商合入对应的板级驱动补丁，完成对OpenHarmony的基线适配。

Linux社区LTS 4.19.y分支信息请查看[kernel官网](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/?h=linux-4.19.y)；

Linux社区LTS 5.10.y分支信息请查看[kernel官网](https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/log/?h=linux-5.10.y)。

内核的Patch组成模块，在编译构建流程中，针对具体芯片平台，合入对应的架构驱动代码，进行编译对应的内核镜像。所有补丁来源均遵守GPL-2.0协议。

## 特定芯片架构驱动补丁（比如Hi3516DV300）<a name="section1521510717399"></a>

vendor厂商提供的特定芯片架构驱动代码：

hi3516dv300_small.patch: 在Hi3516DV300芯片上支持arm架构的内核启动（DTS等）及对应的drm/mmc等驱动的支持。

## 目录<a name="section21571344112"></a>

```
kernel/linux/patches
├── linux-4.19				# linux-4.19 相关patch
│   ├── common_patch
│   │		└── hdf.patch		# linux-4.19 HDF patches
│   └── hi3516dv300_patch
│   		└── hi3516dv300.patch	# linux-4.19 Hi3516D V300 SOC patches
└── linux-5.10
    ├── common_patch
    │		└── hdf.patch		# linux-5.10 HDF patches
    └── hi3516dv300_patch
    │		└── hi3516dv300.patch	# linux-5.10 Hi3516D V300 SOC patches
    └── rkrk3568_patch
    		├── kernel.patch		# linux-5.10 rk3568 SOC patches
    		└── hdf.patch		# linux-5.10 rk3568 定制 HDF patches
```

## 使用说明<a name="section1393789267"></a>

1. 合入HDF补丁

	在kernel/linux/build仓中，按照kernel.mk中HDF的补丁合入方法，合入不同内核版本对应的HDF内核补丁：
	
	```
	$(OHOS_BUILD_HOME)/drivers/hdf_core/adapter/khdf/linux/patch_hdf.sh $(OHOS_BUILD_HOME) $(KERNEL_SRC_TMP_PATH) $(KERNEL_PATCH_PATH) $(DEVICE_NAME)
	```

2. 合入芯片平台驱动补丁

	以Hi3516DV300为例：
	
	在kernel/linux/build仓中，按照kernel.mk中的芯片组件所对应的patch路径规则及命名规则，将对应的芯片组件patch放到对应路径下：
	
	```
	DEVICE_PATCH_DIR := $(OHOS_BUILD_HOME)/kernel/linux/patches/${KERNEL_VERSION}/$(DEVICE_NAME)_patch
	DEVICE_PATCH_FILE := $(DEVICE_PATCH_DIR)/$(DEVICE_NAME).patch
	```

3. 修改自己所需要编译的config

	在kernel/linux/build仓中，按照kernel.mk中的芯片组件所对应的patch路径规则及命名规则，将对应的芯片组件config放到对应路径下：
	
	```
	KERNEL_CONFIG_PATH := $(OHOS_BUILD_HOME)/kernel/linux/config/${KERNEL_VERSION}
	DEFCONFIG_FILE := $(DEVICE_NAME)_$(BUILD_TYPE)_defconfig
	```
	
	> **须知：** 
	>
	>由于OpenHarmony工程的编译构建流程中会拷贝kernel/linux/linux-\*\.\*的代码环境后进行打补丁动作，在使用OpenHarmony的版本级编译命令前，需要kernel/linux/linux-\*\.\*原代码环境。
	>
	>根据不同系统工程，编译完成后会在out目录下的kernel目录中生成对应实际编译的内核，基于此目录的内核，进行对应的config修改，将最后生成的\.config文件cp到config仓对应的路径文件里，即可生效。
	

## 构建说明<a name="section19369206113115"></a>

以hi3516dv300开源开发板+ubuntu x86主机开发环境为例

使用工程的全量编译命令，编译生成uImage内核镜像

```
./build.sh --product-name Hi3516DV300              # 编译hi3516dv300镜像
    --build-target build_kernel                    # 编译hi3516dv300的uImage内核镜像
    --gn-args linux_kernel_version=\"linux-5.10\"  # 编译指定内核版本
```

## 相关仓<a name="section27639463106"></a>

[<u>kernel\_linux\_patches</u>](https://gitee.com/openharmony/kernel_linux_patches)

[<u>kernel\_linux\_config</u>](https://gitee.com/openharmony/kernel_linux_config)
