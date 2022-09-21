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
bool ZswapdMaxReclaimSizeFuzzer(const uint8_t *data, size_t size)
{
    const char *zswapdMaxReclaimSize = "/dev/memcg/memory.zswapd_max_reclaim_size";
    bool ret = MemoryFuzzTest(data, size, zswapdMaxReclaimSize);
    return ret;
}
} // namespace OHOS

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
    OHOS::ZswapdMaxReclaimSizeFuzzer(data, size);
    return 0;
}
