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
#include <cstdlib>
#include "hccommon.h"

namespace OHOS {
bool HcFuzzTest(const uint8_t *data, const char *pathname, size_t size)
{
    uint32_t value = 0;
    uint32_t length = size > sizeof(uint32_t) ? sizeof(uint32_t) : size;
    int ret = access("/mnt/f2fs_mount/", F_OK);
    if (ret < 0) {
        system("mkdir -p /mnt/f2fs_mount/");
        system("mkfs.f2fs -d1 -t1 -O quota /data/image_f2fs");
        system("losetup /dev/block/loop1 /data/image_f2fs");
        system("mount -t f2fs /dev/block/loop1 /mnt/f2fs_mount/");
    }

    int fd = open(pathname, O_RDWR);
    if (fd < 0) {
        return false;
    }

    ret = read(fd, &value, sizeof(value));
    if (ret < 0) {
        close(fd);
        return false;
    }

    ret = write(fd, data, length);
    if (ret < 0) {
        close(fd);
        return false;
    }
    close(fd);
    return true;
}
}