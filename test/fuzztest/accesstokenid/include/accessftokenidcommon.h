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

#ifndef ACCESSFTOKENIDCOMMON_H
#define ACCESSFTOKENIDCOMMON_H
#include <cstdint>

#define FUZZ_PROJECT_NAME "accessftokenidcommon"

namespace OHOS {
namespace Kernel {
namespace AccessToken {
#define ACCESS_TOKEN_ID_IOCTL_BASE    'A'

#ifdef CMDERROR
constexpr unsigned int get_ftoken_id = 0;
constexpr unsigned int set_ftoken_id = 0;
#else
constexpr unsigned int get_ftoken_id = 3;
constexpr unsigned int set_ftoken_id = 4;
#endif

#define ACCESS_TOKENID_GET_FTOKENID \
        _IOR(ACCESS_TOKEN_ID_IOCTL_BASE, get_ftoken_id, unsigned long long)
#define ACCESS_TOKENID_SET_FTOKENID \
        _IOW(ACCESS_TOKEN_ID_IOCTL_BASE, set_ftoken_id, unsigned long long)

#define LIST_NUM_1    1
#define LIST_NUM_2    2
#define TEST_VALUE    123
#define CHILDREN_NUM    3
#define WAIT_FOR_SHELL_OP_TIME    1
#define FATHER_WAIT_TIME    (WAIT_FOR_SHELL_OP_TIME * (CHILDREN_NUM + 1))

#define ACCESS_TOKEN_UID    3020
#define ACCESS_TOKEN_GRPID  3020

#define ACCESS_TOKEN_OTHER_UID      1234
#define ACCESS_TOKEN_OTHER_GRPID    1234

#define INVAL_TOKEN    0xffffffffffffffff

int GetfTokenid(unsigned long long *ftoken);
int SetfTokenid(unsigned long long *ftoken);

void SetUidAndGrp();
void SetUidAndGrpOther();
void GetCurfToken(unsigned long long *ftoken);
void SetRandfTokenAndCheck(unsigned long long *data_ftoken);
void fTokenTest(unsigned long long *data_ftoken);
void ThreadTest(unsigned long long *data_ftoken);
int AccessfTokenidThreadTest(uint8_t *data_ftoken);
int AccessfTokenidGrpTest(uint8_t *data_ftoken);
int AccessfTokenidGrpTestOther(uint8_t *data_ftoken);
} // namespace AccessToken
} // namespace Kernel
} // namespace OHOS

#endif // ACCESSTOKENIDCOMMON_H
