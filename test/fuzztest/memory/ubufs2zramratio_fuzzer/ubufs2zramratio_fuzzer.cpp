/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * SPDX-License-Identifier: GPL-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <cstddef>
#include <cstdint>
#include "memorycommon.h"

namespace OHOS {
bool UbUfs2zramRatioFuzzer(const uint8_t *data, size_t size)
{
    const char *ubUfs2zramRatio = "/dev/memcg/memory.ub_ufs2zram_ratio";
    bool ret = MemoryFuzzTest(data, size, ubUfs2zramRatio);
    return ret;
}
} // namespace OHOS

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
    OHOS::UbUfs2zramRatioFuzzer(data, size);
    return 0;
}
