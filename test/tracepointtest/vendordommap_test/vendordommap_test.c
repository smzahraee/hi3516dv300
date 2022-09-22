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
#include <linux/module.h>
#include <linux/init.h>
#include <linux/kernel.h>

static void vendor_do_mmap(void *data, vm_flags_t *vm_flags, int *err)
{
    pr_info("%s\n", __func__);
}

static int mmap_test_init_module(void)
{
    return register_trace_vendor_do_mmap(&vendor_do_mmap, NULL);
}

static void mmap_test_exit_module(void)
{
    unregister_trace_vendor_do_mmap(&vendor_do_mmap, NULL);
}

/* module entry points */
module_init(mmap_test_init_module);
module_exit(mmap_test_exit_module);
MODULE_LICENSE ("GPL v2");
