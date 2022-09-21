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

#include <trace/hooks/emmc.h>
#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>

static void vendor_fake_boot_partition(void *data, unsigned long prot, int *err)
{
    pr_info("%s\n", __func__);
}

static int fake_boot_partition_test_init_module(void)
{
    return register_trace_vendor_fake_boot_partition(&vendor_fake_boot_partition, NULL);
}

static void fake_boot_partition_test_exit_module(void)
{
    unregister_trace_vendor_fake_boot_partition(&vendor_fake_boot_partition, NULL);
}

/* module entry points */
module_init(fake_boot_partition_test_init_module);
module_exit(fake_boot_partition_test_exit_module);
MODULE_LICENSE ("GPL v2");
