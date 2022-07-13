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
#include <fcntl.h>
#include <unistd.h>
#include <cstdint>
#include <cstdio>
#include <cstdlib>

const char *HC_ENABLE = "/sys/fs/f2fs/loop1/hc_enable";

namespace OHOS {
bool HcEnableFuzzer(const uint8_t *data, size_t size)
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

    int fd = open(HC_ENABLE, O_RDWR);
    if (fd < 0) {
        return false;
    }

    ret = read(fd, &value, sizeof(value));
    if (ret < 0) {
        printf("%s read fail\n", HC_ENABLE);
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
    OHOS::HcEnableFuzzer(data, size);
    return 0;
}
