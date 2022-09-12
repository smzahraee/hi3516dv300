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

#$1 - kernel build script work dir
#$2 - kernel build script stage dir
#$3 - GN target output dir

echo build_kernel
pushd ${1}
./kernel_module_build.sh ${2} ${4} ${5} ${6} ${7} ${8}
mkdir -p ${3}
rm -rf ${3}/../../../kernel.timestamp

# it needs more adaptation
if [ "$5" == "arm" ];then
    cp ${2}/kernel/OBJ/${8}/arch/arm/boot/uImage ${3}/uImage
if [ "$7" == "hispark_phoenix"  ];then
    cp ${2}/kernel/OBJ/${8}/arch/arm/boot/dts/hi3751v350.dtb ${3}/dtbo.img
    cat ${2}/kernel/OBJ/${8}/arch/arm/boot/zImage ${3}/dtbo.img > ${3}/zImage-dtb
else
    cp ${2}/kernel/OBJ/${8}/arch/arm/boot/zImage-dtb ${3}/zImage-dtb
fi

elif [ "$5" == "arm64" ];then
    cp ${2}/kernel/OBJ/${8}/arch/arm64/boot/Image ${3}/Image

elif [ "$5" == "x86_64" ];then
    cp ${2}/kernel/OBJ/${8}/arch/x86/boot/bzImage ${3}/bzImage
fi

popd
