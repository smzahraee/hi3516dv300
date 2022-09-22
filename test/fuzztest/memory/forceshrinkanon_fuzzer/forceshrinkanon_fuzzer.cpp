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

#include <cstdio>
#include <cstdint>
#include <unistd.h>
#include <fcntl.h>

namespace OHOS {
bool ForceShrinkAnonFuzzer(const uint8_t *data, size_t size)
{
    const char *forceShrinkAnon = "/dev/memcg/memory.force_shrink_anon";
    int fd = open(forceShrinkAnon, O_RDWR);
    if (fd < 0) {
        return false;
    }

    int ret = write(fd, data, size);
    if (ret < 0) {
        printf("%s write fail\n", forceShrinkAnon);
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
