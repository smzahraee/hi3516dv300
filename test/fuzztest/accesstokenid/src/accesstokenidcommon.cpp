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
#include <unistd.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <ctime>
#include <fcntl.h>
#include <pthread.h>
#include <sys/syscall.h>
#include <vector>
#include "accesstokenidcommon.h"

namespace OHOS {
namespace Kernel {
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

void SetUidAndGrp()
{
    int ret = 0;
    size_t groupListSize = LIST_NUM_2;
    gid_t groupList[LIST_NUM_2] = {ACCESS_TOKEN_GRPID, TEST_VALUE};

    ret = setgroups(groupListSize, groupList);
    if (ret != 0) {
        return;
    }

    ret = setuid(ACCESS_TOKEN_UID);
    if (ret != 0) {
        printf("SetUidAndGrp setuid error %d \n", ret);
    }

    return;
}

void SetUidAndGrpOther()
{
    int ret = 0;
    size_t groupListSize = LIST_NUM_1;
    gid_t groupList[LIST_NUM_1] = {ACCESS_TOKEN_OTHER_GRPID};

    ret = setgroups(groupListSize, groupList);
    if (ret != 0) {
        return;
    }

    ret = setuid(ACCESS_TOKEN_OTHER_UID);
    if (ret != 0) {
        printf("SetUidAndGrp setuid error %d \n", ret);
    }

    return;
}

void SetRandTokenAndCheck(unsigned long long *data_token)
{
    pid_t pid = getpid();
    pid_t tid = syscall(__NR_gettid);
    unsigned long long token = INVAL_TOKEN;
    unsigned long long tokenSet = *data_token;

    SetTokenid(&tokenSet);
    GetTokenid(&token);

    if (token != tokenSet) {
        printf("pid:%d tid:%d token test failed, token:%llu tokenSet:%llu\n",
               pid, tid, token, tokenSet);
    } else {
        printf("pid:%d tid:%d token test succeed, token:%llu tokenSet:%llu\n",
               pid, tid, token, tokenSet);
    }

    sleep(WAIT_FOR_SHELL_OP_TIME);

    GetTokenid(&token);
    if (token != tokenSet) {
        printf("pid:%d tid:%d token test failed, token:%llu tokenSet:%llu\n",
               pid, tid, token, tokenSet);
    } else {
        printf("pid:%d tid:%d token test succeed, token:%llu tokenSet:%llu\n",
               pid, tid, token, tokenSet);
    }
    return;
}

void *TokenTest(void *data_token)
{
    SetRandTokenAndCheck(static_cast<unsigned long long *>(data_token));

    return nullptr;
}

void ThreadTest(void *data_token)
{
    pthread_t id_1;
    pthread_t id_2;
    pthread_t id_3;
    int ret = 0;

    ret = pthread_create(&id_1, nullptr, TokenTest, data_token);
    if (ret != 0) {
        return;
    }
  
    ret = pthread_create(&id_2, nullptr, TokenTest, data_token);
    if (ret != 0) {
        return;
    }

    ret = pthread_create(&id_3, nullptr, TokenTest, data_token);
    if (ret != 0) {
        return;
    }

    pthread_join(id_1, nullptr);
    pthread_join(id_2, nullptr);
    pthread_join(id_3, nullptr);

    return;
}

int AccessTokenidThreadTest(uint8_t *data_token)
{
    TokenTest(static_cast<void *>(data_token));
    ThreadTest(static_cast<void *>(data_token));
    return 0;
}

int AccessTokenidGrpTest(uint8_t *data_token)
{
    SetUidAndGrp();
    TokenTest(static_cast<void *>(data_token));
    ThreadTest(static_cast<void *>(data_token));
    return 0;
}

int AccessTokenidGrpTestOther(uint8_t *data_token)
{
    SetUidAndGrpOther();
    TokenTest(static_cast<void *>(data_token));
    ThreadTest(static_cast<void *>(data_token));
    return 0;
}
} // namespace AccessToken
} // namespace Kernel
} // namespace OHOS
