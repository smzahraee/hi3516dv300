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
/* SPDX-License-Identifier: GPL-2.0 */

#undef TRACE_SYSTEM
#define TRACE_SYSTEM emmc

#define TRACE_INCLUDE_PATH trace/hooks
#if !defined(_TRACE_HOOKS_EMMC_H) || defined(TRACE_HEADER_MULTI_READ)
#define _TRACE_HOOKS_EMMC_H

#include <trace/hooks/vendor_hooks.h>
#include <linux/tracepoint.h>

DECLARE_HOOK(vendor_aml_emmc_partition,
	TP_PROTO(unsigned long prot, int *err),
	TP_ARGS(prot, err)
);

DECLARE_HOOK(vendor_fake_boot_partition,
	TP_PROTO(unsigned long prot, int *err),
	TP_ARGS(prot, err)
);

#endif

/* This part must be outside protection */
#include <trace/define_trace.h>
