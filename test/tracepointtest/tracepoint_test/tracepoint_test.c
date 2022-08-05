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
