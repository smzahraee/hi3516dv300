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
#include <fcntl.h>
#include <unistd.h>
#include <cstdint>
#include "memorycommon.h"

namespace OHOS {
bool MemoryFuzzTest(const uint8_t *data, size_t size, const char *pathname)
{
    uint32_t value = 0;

    int fd = open(pathname, O_RDWR);
    if (fd < 0) {
        return false;
    }

    int ret = read(fd, &value, sizeof(value));
    if (ret < 0) {
        close(fd);
        return false;
    }

    ret = write(fd, data, size);
    if (ret < 0) {
        close(fd);
        return false;
    }

    close(fd);
    return true;
}
}