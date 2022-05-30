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
#ifndef TEST_FUZZTEST_ACCESSTOKENIDCMDERROR_FUZZER_H
#define TEST_FUZZTEST_ACCESSTOKENIDCMDERROR_FUZZER_H

namespace OHOS {
namespace Security {
namespace AccessToken {
    constexpr unsigned char ACCESS_TOKEN_ID_IOCTL_BASE = 'A';
    constexpr unsigned int GET_TOKEN_ID = 0;
    constexpr unsigned int SET_TOKEN_ID = 0;
    constexpr unsigned int GET_FTOKEN_ID = 0;
    constexpr unsigned int SET_FTOKEN_ID = 0;

#define ACCESS_TOKENID_GET_TOKENID \
    _IOR(ACCESS_TOKEN_ID_IOCTL_BASE, GET_TOKEN_ID, unsigned long long)
#define ACCESS_TOKENID_SET_TOKENID \
    _IOW(ACCESS_TOKEN_ID_IOCTL_BASE, SET_TOKEN_ID, unsigned long long)
#define ACCESS_TOKENID_GET_FTOKENID \
    _IOR(ACCESS_TOKEN_ID_IOCTL_BASE, GET_FTOKEN_ID, unsigned long long)
#define ACCESS_TOKENID_SET_FTOKENID \
    _IOW(ACCESS_TOKEN_ID_IOCTL_BASE, SET_FTOKEN_ID, unsigned long long)

    int GetTokenid(unsigned long long *token);
    int SetTokenid(unsigned long long *token);
    int GetfTokenid(unsigned long long *ftoken);
    int SetfTokenid(unsigned long long *ftoken);
} // namespace AccessToken
} // namespace Security
} // namespace OHOS

#endif // TEST_FUZZTEST_ACCESSTOKENIDCMDERROR_FUZZER_H
