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

#include <vector>
#include <cstddef>
#include <cstdint>
#include "__config"
#include "rtg_interface.h"

using namespace std;
using namespace OHOS::RME;
namespace OHOS {
bool SetMarginFuzzTest(const uint8_t *data, size_t size)
{
    bool ret = false;
    constexpr int margin_upper_limit_time = 32000;
    constexpr int margin_lower_limit_time = -32000;
    if (data == nullptr) {
        return ret;
    } else {
        uint8_t *countData = const_cast<uint8_t *>(data);
        int margin = *(reinterpret_cast<int *>(countData));
        if (margin < margin_lower_limit_time || margin > margin_upper_limit_time) {
            return ret;
        }
        int grpId = 2;
        ret = SetMargin(grpId, margin);
    }
    return ret;
}
}

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
    OHOS::SetMarginFuzzTest(data, size);
    return 0;
}
