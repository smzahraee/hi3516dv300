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

#include <cstdio>
#include <cstdlib>
#include <fcntl.h>
#include <cerrno>
#include <unistd.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <sys/ioctl.h>
#include <ctime>
#include <climits>
#include <pthread.h>
#include <sys/syscall.h>
#include <grp.h>
#include "accesstokenidcmderror.h"

namespace OHOS {
namespace Security {
namespace AccessToken {
const char *DEVACCESSTOKENID = "/dev/access_token_id";

int GetTokenid(unsigned long long *token)
{
    int fd = open(DEVACCESSTOKENID, O_RDWR);
    if (fd < 0) {
        return -1;
    }

    int ret = ioctl(fd, ACCESS_TOKENID_GET_TOKENID, token);
    if (ret) {
        close(fd);
        return -1;
    }

    close(fd);
    return 0;
}

int SetTokenid(unsigned long long *token)
{
    int fd = open(DEVACCESSTOKENID, O_RDWR);
    if (fd < 0) {
        return -1;
    }

    int ret = ioctl(fd, ACCESS_TOKENID_SET_TOKENID, token);
    if (ret) {
        close(fd);
        return -1;
    }

    close(fd);
    return 0;
}

int GetfTokenid(unsigned long long *ftoken)
{
    int fd = open(DEVACCESSTOKENID, O_RDWR);
    if (fd < 0) {
        return -1;
    }

    int ret = ioctl(fd, ACCESS_TOKENID_GET_FTOKENID, ftoken);
    if (ret) {
        close(fd);
        return -1;
    }

    close(fd);
    return 0;
}

int SetfTokenid(unsigned long long *ftoken)
{
    int fd = open(DEVACCESSTOKENID, O_RDWR);
    if (fd < 0) {
        return -1;
    }

    int ret = ioctl(fd, ACCESS_TOKENID_SET_FTOKENID, ftoken);
    if (ret) {
        close(fd);
        return -1;
    }

    close(fd);
    return 0;
}
} // namespace AccessToken
} // namespace Security
} // namespace OHOS
