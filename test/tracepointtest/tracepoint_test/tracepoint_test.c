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

#include <trace/hooks/mm.h>
#include <trace/hooks/emmc.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>

static int tracepoint_test_init_module(void)
{
    pr_info("tracepoint test module init\n");
    trace_vendor_do_mmap(NULL, NULL);
    trace_vendor_do_mprotect_pkey(NULL, NULL);
    trace_vendor_aml_emmc_partition(NULL, NULL);
    trace_vendor_fake_boot_partition(NULL, NULL);
    return 0;
}

static void tracepoint_test_exit_module(void)
{
    pr_info("tracepoint test module exit\n");
}

/* module entry points */
module_init(tracepoint_test_init_module);
module_exit(tracepoint_test_exit_module);
MODULE_LICENSE ("GPL v2");
