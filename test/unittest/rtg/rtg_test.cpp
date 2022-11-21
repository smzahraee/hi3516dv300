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

#include "rtg_test.h"
#include <cstdio>
#include <cstdlib>
#include <fcntl.h>
#include <cerrno>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include <sys/wait.h>
#include <sys/ioctl.h>
#include <ctime>
#include <climits>
#include <pthread.h>
#include <sys/syscall.h>
#include <securec.h>
#include <string>
#include <vector>

using namespace testing::ext;
using namespace std;

constexpr size_t MAX_LENGTH = 100;
constexpr size_t MAX_STR_LEN = 100;
const char RTG_SCHED_IPC_MAGIC = 0xAB;
const int RTG_ERR = -1;
const int RTG_SUCC = 0;
const int MAX_TID_NUM = 5;
const int MULTI_FRAME_NUM = 5;

#define CMD_ID_SET_ENABLE \
    _IOWR(RTG_SCHED_IPC_MAGIC, SET_ENABLE, struct rtg_enable_data)
#define CMD_ID_SET_RTG \
    _IOWR(RTG_SCHED_IPC_MAGIC, SET_RTG, struct rtg_str_data)
#define CMD_ID_BEGIN_FRAME_FREQ \
    _IOWR(RTG_SCHED_IPC_MAGIC, BEGIN_FRAME_FREQ, struct proc_state_data)
#define CMD_ID_END_FRAME_FREQ \
    _IOWR(RTG_SCHED_IPC_MAGIC, END_FRAME_FREQ, struct proc_state_data)
#define CMD_ID_END_SCENE \
    _IOWR(RTG_SCHED_IPC_MAGIC, END_SCENE, struct proc_state_data)
#define CMD_ID_SET_MIN_UTIL \
    _IOWR(RTG_SCHED_IPC_MAGIC, SET_MIN_UTIL, struct proc_state_data)
#define CMD_ID_SET_MARGIN \
    _IOWR(RTG_SCHED_IPC_MAGIC, SET_MARGIN, struct proc_state_data)
#define CMD_ID_LIST_RTG_THREAD \
    _IOWR(RTG_SCHED_IPC_MAGIC, LIST_RTG_THREAD, struct rtg_grp_data)
#define CMD_ID_LIST_RTG \
    _IOWR(RTG_SCHED_IPC_MAGIC, LIST_RTG, struct rtg_info)
#define CMD_ID_SET_RTG_ATTR \
    _IOWR(RTG_SCHED_IPC_MAGIC, SET_RTG_ATTR, struct rtg_str_data)
#define CMD_ID_SET_CONFIG \
    _IOWR(RTG_SCHED_IPC_MAGIC, SET_CONFIG, struct rtg_str_data)

struct rtg_enable_data {
    int enable;
    int len;
    char *data;
};

struct rtg_str_data {
    int type;
    int len;
    char *data;
};

struct proc_state_data {
    int grp_id;
    int state_param;
};

enum grp_ctrl_cmd {
    CMD_CREATE_RTG_GRP,
    CMD_ADD_RTG_THREAD,
    CMD_REMOVE_RTG_THREAD,
    CMD_CLEAR_RTG_GRP,
    CMD_DESTROY_RTG_GRP
};

struct rtg_grp_data {
    int rtg_cmd;
    int grp_id;
    int prio_type;
    int rt_cnt;
    int tid_num;
    int tids[MAX_TID_NUM];
};

struct rtg_info {
    int rtg_num;
    int rtgs[MULTI_FRAME_NUM];
};

enum rtg_sched_cmdid {
    SET_ENABLE = 1,
    SET_RTG,
    SET_CONFIG,
    SET_RTG_ATTR,
    BEGIN_FRAME_FREQ = 5,
    END_FRAME_FREQ,
    END_SCENE,
    SET_MIN_UTIL,
    SET_MARGIN,
    LIST_RTG = 10,
    LIST_RTG_THREAD,
    SEARCH_RTG,
    GET_ENABLE,
    RTG_CTRL_MAX_NR,
};

enum rtg_type : int {
    VIP = 0,
    TOP_TASK_KEY,
    NORMAL_TASK,
    RTG_TYPE_MAX,
};

static int BasicOpenRtgNode()
{
    char fileName[] = "/proc/self/sched_rtg_ctrl";
    int fd = open(fileName, O_RDWR);

    if (fd < 0) {
        cout << "open node err." << endl;
    }

    return fd;
}

static int EnableRtg(bool flag)
{
    struct rtg_enable_data enableData;
    char configStr[] = "load_freq_switch:1;sched_cycle:1";

    enableData.enable = flag;
    enableData.len = sizeof(configStr);
    enableData.data = configStr;
    int fd = BasicOpenRtgNode();
    if (fd < 0) {
        return RTG_ERR;
    }
    if (ioctl(fd, CMD_ID_SET_ENABLE, &enableData)) {
        close(fd);
        return RTG_ERR;
    }

    close(fd);
    return 0;
}

static int CreateNewRtgGrp(int prioType, int rtNum)
{
    struct rtg_grp_data grp_data;
    int ret;
    int fd = BasicOpenRtgNode();
    if (fd < 0) {
        return RTG_ERR;
    }
    (void)memset_s(&grp_data, sizeof(struct rtg_grp_data), 0, sizeof(struct rtg_grp_data));
    if ((prioType > 0) && (prioType < RTG_TYPE_MAX)) {
        grp_data.prio_type = prioType;
    }
    if (rtNum > 0) {
        grp_data.rt_cnt = rtNum;
    }
    grp_data.rtg_cmd = CMD_CREATE_RTG_GRP;
    ret = ioctl(fd, CMD_ID_SET_RTG, &grp_data);

    close(fd);
    return ret;
}

static int DestroyRtgGrp(int GrpId)
{
    struct rtg_grp_data grp_data;
    int ret;
    int fd = BasicOpenRtgNode();
    if (fd < 0) {
        return fd;
    }
    (void)memset_s(&grp_data, sizeof(struct rtg_grp_data), 0, sizeof(struct rtg_grp_data));
    grp_data.rtg_cmd = CMD_DESTROY_RTG_GRP;
    grp_data.grp_id = GrpId;
    ret = ioctl(fd, CMD_ID_SET_RTG, &grp_data);

    close(fd);
    return ret;
}

static int AddThreadToRtg(int tid, int grpId, int prioType)
{
    struct rtg_grp_data grp_data;
    int ret;
    int fd = BasicOpenRtgNode();
    if (fd < 0) {
        return fd;
    }
    (void)memset_s(&grp_data, sizeof(struct rtg_grp_data), 0, sizeof(struct rtg_grp_data));
    grp_data.tid_num = 1;
    grp_data.tids[0] = tid;
    grp_data.grp_id = grpId;
    grp_data.rtg_cmd = CMD_ADD_RTG_THREAD;
    grp_data.prio_type = prioType;
    ret = ioctl(fd, CMD_ID_SET_RTG, &grp_data);

    close(fd);
    return ret;
}

static int ClearRtgGrp(int GrpId)
{
    struct rtg_grp_data grp_data;
    int ret;
    int fd = BasicOpenRtgNode();
    if (fd < 0) {
        return fd;
    }
    (void)memset_s(&grp_data, sizeof(struct rtg_grp_data), 0, sizeof(struct rtg_grp_data));
    grp_data.rtg_cmd = CMD_CLEAR_RTG_GRP;
    grp_data.grp_id = GrpId;
    ret = ioctl(fd, CMD_ID_SET_RTG, &grp_data);
    if (ret < 0) {
        return ret;
    }

    close(fd);
    return ret;
};

static int BeginFrameFreq(int grpId, int stateParam)
{
    int ret = 0;
    struct proc_state_data state_data;
    state_data.grp_id = grpId;
    state_data.state_param = stateParam;
    int fd = BasicOpenRtgNode();
    if (fd < 0) {
        return fd;
    }
    ret = ioctl(fd, CMD_ID_BEGIN_FRAME_FREQ, &state_data);

    close(fd);
    return ret;
}

static int EndFrameFreq(int grpId)
{
    int ret = 0;
    struct proc_state_data state_data;
    state_data.grp_id = grpId;
    state_data.state_param = 0;
    int fd = BasicOpenRtgNode();
    if (fd < 0) {
            return fd;
        }
    ret = ioctl(fd, CMD_ID_END_FRAME_FREQ, &state_data);

    close(fd);
    return ret;
}

static int EndScene(int grpId)
{
    int ret = 0;
    struct proc_state_data state_data;
    state_data.grp_id = grpId;

    int fd = BasicOpenRtgNode();
    if (fd < 0) {
       return fd;
    }
    ret = ioctl(fd, CMD_ID_END_SCENE, &state_data);

    close(fd);
    return ret;
}

static int SetStateParam(unsigned int cmd, int grpId, int stateParam)
{
    int ret = 0;
    struct proc_state_data state_data;
    state_data.grp_id = grpId;
    state_data.state_param = stateParam;

    int fd = BasicOpenRtgNode();
    if (fd < 0) {
        return fd;
    }
    ret = ioctl(fd, cmd, &state_data);

    close(fd);
    return ret;
}


static int ListRtgThread(int grpId, vector<int> *rs)
{
    int ret = 0;
    struct rtg_grp_data grp_data;
    int fd = BasicOpenRtgNode();
    if (fd < 0) {
        return fd;
    }
    if (!rs) {
       return RTG_ERR;
    }
    (void)memset_s(&grp_data, sizeof(struct rtg_grp_data), 0, sizeof(struct rtg_grp_data));
    grp_data.grp_id = grpId;
    ret = ioctl(fd, CMD_ID_LIST_RTG_THREAD, &grp_data);
    if (ret < 0) {
        return ret;
    } else {
        rs->clear();
        for (int i = 0; i < grp_data.tid_num; i++) {
            rs->push_back(grp_data.tids[i]);
        }
    }

    close(fd);
    return ret;
}

static int ListRtgGroup(vector<int> *rs)
{
    int ret = 0;
    struct rtg_info rtg_info;
    int fd = BasicOpenRtgNode();
    if (fd < 0) {
        return fd;
    }
    if (!rs) {
        return RTG_ERR;
    }
    (void)memset_s(&rtg_info, sizeof(struct rtg_info), 0, sizeof(struct rtg_info));
    ret = ioctl(fd, CMD_ID_LIST_RTG, &rtg_info);
    if (ret < 0) {
        return ret;
    } else {
        rs->clear();
        for (int i = 0; i < rtg_info.rtg_num; i++) {
            rs->push_back(rtg_info.rtgs[i]);
        }
    }

    close(fd);
    return ret;
}

static int SetFrameRateAndPrioType(int rtgId, int rate, int rtgType)
{
    int ret = 0;
    char str_data[MAX_LENGTH] = {};
    (void)sprintf_s(str_data, sizeof(str_data), "rtgId:%d;rate:%d;type:%d", rtgId, rate, rtgType);
    struct rtg_str_data strData;
    strData.len = strlen(str_data);
    strData.data = str_data;

    int fd = BasicOpenRtgNode();
    if (fd < 0) {
        return fd;
    }
    ret = ioctl(fd, CMD_ID_SET_RTG_ATTR, &strData);

    close(fd);
    return ret;
}

static int SetMaxVipRtgs(int rtframe)
{
    int ret = 0;
    char str_data[MAX_STR_LEN] = {};
    (void)sprintf_s(str_data, sizeof(str_data), "rtframe:%d", rtframe);
    struct rtg_str_data strData;
    strData.len = strlen(str_data);
    strData.data = str_data;

    int fd = BasicOpenRtgNode();
    if (fd < 0) {
        return fd;
    }
    ret = ioctl(fd, CMD_ID_SET_CONFIG, &strData);

    close(fd);
    return ret;
}

static int AddThreadsToRtg(vector<int> tids, int grpId, int prioType)
{
    struct rtg_grp_data grp_data;
    int ret;
    int fd = BasicOpenRtgNode();

    if (fd < 0) {
        return fd;
    }
    (void)memset_s(&grp_data, sizeof(struct rtg_grp_data), 0, sizeof(struct rtg_grp_data));
    int num = static_cast<int>(tids.size());
    if (num > MAX_TID_NUM) {
        return -1;
    }
    grp_data.tid_num = num;
    grp_data.grp_id = grpId;
    grp_data.rtg_cmd = CMD_ADD_RTG_THREAD;
    grp_data.prio_type = prioType;
    for (int i = 0; i < num; i++) {
        if (tids[i] < 0) {
            return -1;
        }
        grp_data.tids[i] = tids[i];
    }
    ret = ioctl(fd, CMD_ID_SET_RTG, &grp_data);

    close(fd);
    return ret;
}

void RtgTest::SetUp() {
    // must enable rtg before use the interface
    int ret = EnableRtg(true);
    ASSERT_EQ(RTG_SUCC, ret);
}

void RtgTest::TearDown() {
    // disable rtg after use the interface
    int ret = EnableRtg(false);
    ASSERT_EQ(RTG_SUCC, ret);
}

void RtgTest::SetUpTestCase() {}

void RtgTest::TearDownTestCase() {}

/**
 * @tc.name: setEnableSucc
 * @tc.desc: Verify the enable rtg function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, setEnableSucc, Function | MediumTest | Level1)
{
    int ret;

    // test set enable again
    ret = EnableRtg(true);
    ASSERT_EQ(RTG_SUCC, ret);

    // test set disable again
    ret = EnableRtg(false);
    ASSERT_EQ(RTG_SUCC, ret);
}

/**
 * @tc.name: createAndDestroyRtgSucc
 * @tc.desc: Verify the create and destroy rtggrp function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, createAndDestroyRtgSucc, Function | MediumTest | Level1)
{
    int ret;
    int grpId;

    grpId = CreateNewRtgGrp(NORMAL_TASK, 0);
    ASSERT_GT(grpId, 0);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, 0);
}

/**
 * @tc.name: destoryErrorRtgGrp
 * @tc.desc: Verify Destroy function with error param.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, destoryErrorRtgGrp, Function | MediumTest | Level1)
{
    int ret;
    ret = DestroyRtgGrp(-1);
    ASSERT_NE(RTG_SUCC, ret);
}

/**
 * @tc.name: addRtgGrpSucc
 * @tc.desc: Verify add rtg function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, addRtgGrpSucc, Function | MediumTest | Level1)
{
    int ret;
    int grpId;
    int pid = getpid();

    grpId = CreateNewRtgGrp(VIP, 0);
    ASSERT_GT(grpId, 0);
    ret = AddThreadToRtg(pid, grpId, VIP);
    ASSERT_EQ(ret, 0);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, 0);
}

/**
 * @tc.name: addRtgGrpFail
 * @tc.desc: Verify add rtg function with error param.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, addRtgGrpFail, Function | MediumTest | Level1)
{
    int ret;
    int grpId;
    int pid = getpid();

    grpId = CreateNewRtgGrp(VIP, 0);
    ASSERT_GT(grpId, 0);

    // error tid
    ret = AddThreadToRtg(-1, grpId, VIP);
    ASSERT_NE(ret, 0);

    // error grpid
    ret=AddThreadToRtg(pid, -1, VIP);
    ASSERT_NE(ret, RTG_SUCC);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, 0);
}

/**
 * @tc.name: clearRtgSucc
 * @tc.desc: Verify clear rtg function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, clearRtgSucc, Function | MediumTest | Level1)
{
    int ret;
    int grpId;
    int pid = getpid();

    grpId = CreateNewRtgGrp(VIP, 0);
    ASSERT_GT(grpId, 0);
    ret = AddThreadToRtg(pid, grpId, VIP);
    ASSERT_EQ(ret, RTG_SUCC);
    ret = ClearRtgGrp(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
}

/**
 * @tc.name: clearRtgFail
 * @tc.desc: Verify clear rtg function with error param.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, clearRtgFail, Function | MediumTest | Level1)
{
    int ret;

    ret = ClearRtgGrp(-1);
    ASSERT_NE(ret, RTG_SUCC);
}

/**
 * @tc.name: begainFrameFreqSucc
 * @tc.desc: Verify rtg frame start function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, begainFrameFreqSucc, Function | MediumTest | Level1)
{
    int ret;
    int grpId;

    grpId = CreateNewRtgGrp(VIP, 0);
    ASSERT_GT(grpId, 0);
    ret = BeginFrameFreq(grpId, 0);
    ASSERT_EQ(ret, RTG_SUCC);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
}

/**
 * @tc.name: begainFrameFreqFail
 * @tc.desc: Verify rtg frame start function with error param.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, begainFrameFreqFail, Function | MediumTest | Level1)
{
    int ret;
    ret = BeginFrameFreq(-1, 0);
    ASSERT_NE(ret, RTG_SUCC);
}

/**
 * @tc.name: endFrameFreqSucc
 * @tc.desc: Verify rtg frame end function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, endFrameFreqSucc, Function | MediumTest | Level1)
{
    int ret;
    int grpId;

    grpId = CreateNewRtgGrp(VIP, 0);
    ASSERT_GT(grpId, 0);
    ret = EndFrameFreq(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
}

/**
 * @tc.name: endFrameFreqFail
 * @tc.desc: Verify rtg frame end function with error param.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, endFrameFreqFail, Function | MediumTest | Level1)
{
    int ret;
    ret = EndFrameFreq(-1);
    ASSERT_NE(ret, RTG_SUCC);
}

/**
 * @tc.name: endSceneSucc
 * @tc.desc: Verify scene end function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, endSceneSucc, Function | MediumTest | Level1)
{
    int ret;
    int grpId;

    grpId = CreateNewRtgGrp(VIP, 0);
    ASSERT_GT(grpId, 0);
    ret = EndScene(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
}

/**
 * @tc.name: endSceneFail
 * @tc.desc: Verify scene end function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, endSceneFail, Function | MediumTest | Level1)
{
    int ret;

    ret = EndScene(-1);
    ASSERT_NE(ret, RTG_SUCC);
}

/**
 * @tc.name: setMinUtilSucc
 * @tc.desc: Verify set min util function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, setMinUtilSucc, Function | MediumTest | Level1)
{
    int ret;
    int grpId;

    grpId = CreateNewRtgGrp(VIP, 0);
    ASSERT_GT(grpId, 0);
    ret = SetStateParam(CMD_ID_SET_MIN_UTIL, grpId, 0);
    ASSERT_EQ(ret, RTG_SUCC);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
}

/**
 * @tc.name: setMinUtilFail
 * @tc.desc: Verify set min util function with Error Param.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, setMinUtilFail, Function | MediumTest | Level1)
{
    int ret;

    ret = SetStateParam(CMD_ID_SET_MIN_UTIL, -1, 0);
    ASSERT_NE(ret, RTG_SUCC);
}

/**
 * @tc.name: setMarginSucc
 * @tc.desc: Verify set min margin function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, setMarginSucc, Function | MediumTest | Level1)
{
    int ret;
    int grpId;

    grpId = CreateNewRtgGrp(VIP, 0);
    ASSERT_GT(grpId, 0);
    ret = SetStateParam(CMD_ID_SET_MARGIN, grpId, 0);
    ASSERT_EQ(ret, RTG_SUCC);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
}

/**
 * @tc.name: setMarginFail
 * @tc.desc: Verify set min margin function with error param.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, setMarginFail, Function | MediumTest | Level1)
{
    int ret;

    ret = SetStateParam(CMD_ID_SET_MARGIN, -1, 0);
    ASSERT_NE(ret, RTG_SUCC);
}

/**
 * @tc.name: listRtgThreadSucc
 * @tc.desc: Verify list rtg thread function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, ListRtgThreadSucc, Function | MediumTest | Level1)
{
    int ret;
    int grpId;
    vector<int> rs;

    grpId = CreateNewRtgGrp(VIP, 0);
    ASSERT_GT(grpId, 0);
    ret = ListRtgThread(grpId, &rs);
    ASSERT_EQ(ret, 0);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, 0);
}

/**
 * @tc.name: listRtgThreadFail
 * @tc.desc: Verify list rtg thread function with null vector input.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, ListRtgThreadFail, Function | MediumTest | Level1)
{
    int ret;
    int grpId;
    vector<int> rs;

    grpId = CreateNewRtgGrp(VIP, 0);
    ASSERT_GT(grpId, 0);
    ret = ListRtgThread(grpId, nullptr);
    ASSERT_NE(ret, RTG_SUCC);
    ret = ListRtgThread(-1, &rs);
    ASSERT_NE(ret, RTG_SUCC);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
}

/**
 * @tc.name: listRtgSucc
 * @tc.desc: Verify list rtg function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, ListRtgSucc, Function | MediumTest | Level1)
{
    int ret;
    vector<int> rs;

    ret = ListRtgGroup(&rs);
    ASSERT_EQ(ret, RTG_SUCC);
}

/**
 * @tc.name: listRtgFail
 * @tc.desc: Verify list rtg function with error param.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, ListRtgFail, Function | MediumTest | Level1)
{
    int ret;

    ret = ListRtgGroup(nullptr);
    ASSERT_NE(ret, RTG_SUCC);
}

/**
 * @tc.name: SetRtgAttrSucc
 * @tc.desc: Verify rtg attr set function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, SetRtgAttrSucc, Function | MediumTest | Level1)
{
    int ret;
    int grpId;

    grpId = CreateNewRtgGrp(VIP, 0);
    ASSERT_GT(grpId, 0);
    ret = SetFrameRateAndPrioType(grpId, 60, VIP);
    ASSERT_EQ(ret, RTG_SUCC);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
}

/**
 * @tc.name: SetRtgAttrFail
 * @tc.desc: Verify rtg attr set function with error param.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, SetRtgAttrFail, Function | MediumTest | Level1)
{
    int ret;
    int grpId;
    grpId = CreateNewRtgGrp(VIP, 0);
    ASSERT_GT(grpId, 0);
    ret = SetFrameRateAndPrioType(grpId, 90, -1);
    ASSERT_NE(ret, RTG_SUCC);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
}

/**
 * @tc.name: SetMaxVipRtgSucc
 * @tc.desc: Verify rtg max vip num set function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, SetMaxVipRtgSucc, Function | MediumTest | Level1)
{
    int ret;

    ret = SetMaxVipRtgs(2);
    ASSERT_EQ(ret, RTG_SUCC);
}

/**
 * @tc.name: SetMaxVipRtgFail
 * @tc.desc: Verify rtg max vip num set function with error param.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, SetMaxVipRtgFail, Function | MediumTest | Level1)
{
    int ret;

    // set 0 vip num
    ret = SetMaxVipRtgs(0);
    ASSERT_NE(ret, RTG_SUCC);

    // set large vip num
    ret = SetMaxVipRtgs(50000);
    ASSERT_NE(ret, RTG_SUCC);
}

/**
 * @tc.name: RtgAddMutipleThreadsSucc
 * @tc.desc: Verify rtg multiple add function.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, RtgAddMutipleThreadsSucc, Function | MediumTest | Level1)
{
    int ret;
    int pid[3];
    vector<int> threads;
    int grpId;

    for (int i = 0; i < 3; i++) {
        pid[i] = fork();
        ASSERT_TRUE(pid[i] >= 0) << "> parent: fork errno = " << errno;
        if (pid[i] == 0) {
            usleep(50000);
             _Exit(0);
        }
        threads.push_back(pid[i]);
    }
    grpId = CreateNewRtgGrp(NORMAL_TASK, 0);
    ASSERT_GT(grpId, 0);
    ret = AddThreadsToRtg(threads, grpId, NORMAL_TASK);
    ASSERT_EQ(ret, RTG_SUCC);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
}

/**
 * @tc.name: RtgAddMutipleThreadsOutOfLimit
 * @tc.desc: Verify rtg multiple add function with out of limit threads.
 * @tc.type: FUNC
 */
HWTEST_F(RtgTest, RtgAddMutipleThreadsOutOfLimit, Function | MediumTest | Level1)
{
    int ret;
    int pid[8];
    vector<int> threads;
    int grpId;

    for (int i = 0; i < 8; i++) {
        pid[i] = fork();
        ASSERT_TRUE(pid[i] >= 0) << "> parent: fork errno = " << errno;
        if (pid[i] == 0) {
            usleep(50000);
            _Exit(0);
        }
    threads.push_back(pid[i]);
    }
    grpId = CreateNewRtgGrp(NORMAL_TASK, 0);
    ASSERT_GT(grpId, 0);
    ret = AddThreadsToRtg(threads, grpId, NORMAL_TASK);
    ASSERT_NE(ret, RTG_SUCC);
    ret = DestroyRtgGrp(grpId);
    ASSERT_EQ(ret, RTG_SUCC);
}
