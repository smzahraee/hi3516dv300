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
#include "memorycommon.h"

const char *AVAIL_BUFFERS = "/dev/memcg/memory.avail_buffers";

namespace OHOS {
bool AvailBuffersFuzzer(const uint8_t *data, size_t size)
{
    bool ret = MemoryFuzzTest(data, size, AVAIL_BUFFERS);
    return ret;
}
} // namespace OHOS

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
    OHOS::AvailBuffersFuzzer(data, size);
    return 0;
}
