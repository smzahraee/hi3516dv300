/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * SPDX-License-Identifier: GPL-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 reinterpret_cast
 static_cast
 */

#include <vector>
#include <cstddef>
#include <cstdint>
#include "__config"
#include "accesstokenidcommon.h"

using namespace std;
using namespace OHOS::Kernel::AccessToken;
namespace OHOS {
bool GetTokenidCmdCorrectFuzzTest(const uint8_t *data, size_t size)
{
    bool ret = GetTokenidCmdFuzzTest(data, size);
    return ret;
}
}

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
    OHOS::GetTokenidCmdCorrectFuzzTest(data, size);
    return 0;
}
