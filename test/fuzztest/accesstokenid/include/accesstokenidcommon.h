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

#ifndef ACCESSTOKENIDCOMMON_H
#define ACCESSTOKENIDCOMMON_H
#include <cstddef>
#include <cstdint>

#define FUZZ_PROJECT_NAME "accesstokenidcommon"

namespace OHOS {
namespace Kernel {
namespace AccessToken {
#define ACCESS_TOKEN_ID_IOCTL_BASE    'A'

#ifdef CMDERROR
#define GET_TOKEN_ID    0
#define SET_TOKEN_ID    0
#define GET_GTOKEN_ID   0
#define SET_GTOKEN_ID   0
#else
#define GET_TOKEN_ID    1
#define SET_TOKEN_ID    2
#define GET_GTOKEN_ID   3
#define SET_GTOKEN_ID   4
#endif

#define ACCESS_TOKENID_GET_TOKENID \
        _IOR(ACCESS_TOKEN_ID_IOCTL_BASE, GET_TOKEN_ID, unsigned long long)
#define ACCESS_TOKENID_SET_TOKENID \
        _IOW(ACCESS_TOKEN_ID_IOCTL_BASE, SET_TOKEN_ID, unsigned long long)
#define ACCESS_TOKENID_GET_FTOKENID \
        _IOR(ACCESS_TOKEN_ID_IOCTL_BASE, GET_GTOKEN_ID, unsigned long long)
#define ACCESS_TOKENID_SET_FTOKENID \
        _IOW(ACCESS_TOKEN_ID_IOCTL_BASE, SET_GTOKEN_ID, unsigned long long)

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

int GetTokenid(unsigned long long *token);
int SetTokenid(unsigned long long *token);
int GetfTokenid(unsigned long long *ftoken);
int SetfTokenid(unsigned long long *ftoken);

void SetUidAndGrp();
void SetUidAndGrpOther();
void GetCurToken(unsigned long long *token);
void SetRandTokenAndCheck(unsigned long long *dataToken);
void TokenTest(unsigned long long *dataToken);
void ThreadTest(unsigned long long *dataToken);
int AccessTokenidThreadTest(uint8_t *dataToken);
int AccessTokenidGrpTest(uint8_t *dataToken);
int AccessTokenidGrpTestOther(uint8_t *dataToken);

void GetCurfToken(unsigned long long *ftoken);
void SetRandfTokenAndCheck(unsigned long long *dataFtoken);
void FTokenTest(unsigned long long *dataFtoken);
void ThreadTest(unsigned long long *dataFtoken);
int AccessfTokenidThreadTest(uint8_t *dataFtoken);
int AccessfTokenidGrpTest(uint8_t *dataFtoken);
int AccessfTokenidGrpTestOther(uint8_t *dataFtoken);
bool SetfTokenidCmdFuzzTest(const uint8_t *data, size_t size);
bool GetfTokenidCmdFuzzTest(const uint8_t *data, size_t size);
bool SetTokenidCmdFuzzTest(const uint8_t *data, size_t size);
bool GetTokenidCmdFuzzTest(const uint8_t *data, size_t size);
} // namespace AccessToken
} // namespace Kernel
} // namespace OHOS

#endif // ACCESSTOKENIDCOMMON_H
