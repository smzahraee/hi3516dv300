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

const char *ZRAM_CRITICAL_THRESHOLD = "/dev/memcg/memory.zram_critical_threshold";

namespace OHOS {
bool ZramCriticalThresholdFuzzer(const uint8_t *data, size_t size)
{
    uint32_t value = 0;

    int fd = open(ZRAM_CRITICAL_THRESHOLD, O_RDWR);
    if (fd < 0) {
        return false;
    }

    int ret = read(fd, &value, sizeof(value));
    if (ret < 0) {
        printf("%s read fail\n", ZRAM_CRITICAL_THRESHOLD);
        close(fd);
        return false;
    }

    ret = write(fd, data, size);
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
    OHOS::ZramCriticalThresholdFuzzer(data, size);
    return 0;
}
