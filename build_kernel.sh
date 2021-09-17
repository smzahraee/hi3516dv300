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


pushd ${1}
./kernel_module_build.sh ${2} ${4} ${5} ${6} ${7} ${8}
mkdir -p ${3}
cp ${2}/kernel/OBJ/${8}/arch/arm/boot/uImage ${3}/uImage
popd
