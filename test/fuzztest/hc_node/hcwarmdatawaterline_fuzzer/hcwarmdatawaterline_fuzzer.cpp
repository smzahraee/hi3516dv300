/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <cstddef>
#include <cstdint>
#include <cstdlib>
#include <cstdio>
#include <sys/types.h>
#include <fcntl.h>
#include <unistd.h>

const char *HC_WARM_DATA_WATERLINE = "/sys/fs/f2fs/loop1/hc_warm_data_waterline";

namespace OHOS {
bool HcWarmDataWaterLineFuzzTest(const uint8_t *data, size_t size)
{
    uint32_t value = 0;
    uint32_t length = size > sizeof(uint32_t) ? sizeof(uint32_t) : size;
    int ret = access("/mnt/f2fs_mount/", F_OK);
    if (ret < 0) {
        system("mkdir -p /mnt/f2fs_mount/");
        system("mkfs.f2fs -d1 -t1 -O quota /data/image_f2fs");
        system("losetup /dev/block/loop1 /data/image_f2fs");
        system("mount -t f2fs /dev/block/loop1 /mnt/f2fs_mount/");
    }

    int fd = open(HC_WARM_DATA_WATERLINE, O_RDWR);
    if (fd < 0) {
        return false;
    }

    ret = read(fd, &value, sizeof(value));
    if (ret < 0) {
        printf("%s read fail\n", HC_WARM_DATA_WATERLINE);
        close(fd);
        return false;
    }

    ret = write(fd, data, length);
    if (ret < 0) {
        close(fd);
        return false;
    }
    close(fd);
    return true;
}
} // namespace OHOS

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
    OHOS::HcWarmDataWaterLineFuzzTest(data, size);
    return 0;
}
