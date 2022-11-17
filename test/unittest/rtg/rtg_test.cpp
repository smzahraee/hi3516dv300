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

// constexpr size_t MAX_LENGTH = 100;
// constexpr size_t MAX_STR_LEN = 100;
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
