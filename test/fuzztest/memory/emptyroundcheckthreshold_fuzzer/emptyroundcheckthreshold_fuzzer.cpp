/*
 * Copyright (c) 2022 Huawei Device Co., Ltd.
 * SPDX-License-Identifier: GPL-2.0
 *
 * Legacy blkg rwstat helpers enabled by CONFIG_BLK_CGROUP_RWSTAT.
 * Do not use in new code.
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
bool EmptyRoundCheckThresholdFuzzer(const uint8_t *data, size_t size)
{
    const char *emptyRoundCheckThreshold = "/dev/memcg/memory.empty_round_check_threshold";
    bool ret = MemoryFuzzTest(data, size, emptyRoundCheckThreshold);
    return ret;
}
} // namespace OHOS

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
    OHOS::EmptyRoundCheckThresholdFuzzer(data, size);
    return 0;
}
