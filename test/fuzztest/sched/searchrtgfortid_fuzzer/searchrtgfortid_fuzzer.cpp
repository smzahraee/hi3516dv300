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

#include <vector>
#include <cstddef>
#include <cstdint>
#include "__config"
#include "rtg_interface.h"

using namespace std;
using namespace OHOS::RME;
namespace OHOS {
bool SearchRtgForTidFuzzTest(const uint8_t *data, size_t size)
{
    bool ret = false;
    if (data == nullptr) {
        return ret;
    } else {
        uint8_t *countData = const_cast<uint8_t *>(data);
        int tid = *(reinterpret_cast<int *>(countData));
        if (tid <= 0) {
            return ret;
        }
        ret = SearchRtgForTid(tid);
    }
    return ret;
}
}

extern "C" int LLVMFuzzerTestOneInput(const uint8_t *data, size_t size)
{
    OHOS::SearchRtgForTidFuzzTest(data, size);
    return 0;
}
