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
#include "accesstokenidcmdcorrect.h"
#include "getftokenidcmdcorrect_fuzzer.h"

using namespace std;
using namespace OHOS::Security::AccessToken;
namespace OHOS {
bool GetfTokenidCmdCorrectFuzzTest(const uint8_t *data, size_t size)
{
    bool ret = false;
    if ((data == nullptr) || (size < sizeof(unsigned long long))) {
        return ret;
    } else {
        unsigned long long tokenId = *(reinterpret_cast<const unsigned long long *>(data));
        ret = GetfTokenid(&tokenId);
    }
    return ret;
}
}

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
    OHOS::GetfTokenidCmdCorrectFuzzTest(data, size);
    return 0;
}
