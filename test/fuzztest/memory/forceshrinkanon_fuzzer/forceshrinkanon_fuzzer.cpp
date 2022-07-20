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

#include <cstdio>
#include <cstddef>
#include <cstdint>
#include <unistd.h>
#include <fcntl.h>
#include "memorycommon.h"

const char *FORCE_SHRINK_ANON = "/dev/memcg/memory.force_shrink_anon";

namespace OHOS {
bool ForceShrinkAnonFuzzer(const uint8_t *data, size_t size)
{
    int fd = open(FORCE_SHRINK_ANON, O_RDWR);
    if (fd < 0) {
        return false;
    }

    int ret = write(fd, data, size);
    if (ret < 0) {
        printf("%s write fail\n", FORCE_SHRINK_ANON);
        close(fd);
        return false;
    }

    close(fd);
    return true;
}
} // namespace OHOS

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
    OHOS::ForceShrinkAnonFuzzer(data, size);
    return 0;
}
