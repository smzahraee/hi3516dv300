#!/bin/sh
################################################################################
#
# Copyright (C) 2022 Huawei Device Co., Ltd.
# SPDX-License-Identifier: GPL-2.0
#
# Legacy blkg rwstat helpers enabled by CONFIG_BLK_CGROUP_RWSTAT.
# Do not use in new code.
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
# File: tst_oh.sh
#
# Description: OpenHarmony linuxkerneltest test library for shell
#
# Authors:     Ma Feng - mafeng.ma@huawei.com
#
# History:     Mar 15 2022 - init scripts
#
################################################################################

[ -n "$TST_LTB_LOADED" ] && return 0

export TST_PASS=0
export TST_FAIL=0
export TST_BROK=0
export TST_WARN=0
export TST_CONF=0
export TST_COUNT=0
export TST_COLOR_ENABLED=1
export TST_LTB_LOADED=1

trap "tst_brk TBROK 'test interrupted'" INT

tst_flag2color()
{
    local ansi_color_blue='\033[1;34m'
    local ansi_color_green='\033[1;32m'
    local ansi_color_magenta='\033[1;35m'
    local ansi_color_red='\033[1;31m'
    local ansi_color_yellow='\033[1;33m'

    case "$1" in
    TPASS) printf $ansi_color_green;;
    TFAIL) printf $ansi_color_red;;
    TBROK) printf $ansi_color_red;;
    TWARN) printf $ansi_color_magenta;;
    TINFO) printf $ansi_color_blue;;
    TCONF) printf $ansi_color_yellow;;
    esac
}

tst_color_enabled()
{
    [[ $TST_COLOR_ENABLED -eq 1 ]]  && return 1 || return 0
}

tst_print_colored()
{
    tst_color_enabled
    local color=$?


    [ "$color" = "1" ] && tst_flag2color "$1"
    printf "$2"
    [ "$color" = "1" ] && printf '\033[0m'
}

tst_exit()
{
    local ret=0

    if [ $TST_FAIL -gt 0 ]; then
        ret=$((ret|1))
    fi

    if [ $TST_BROK -gt 0 ]; then
        ret=$((ret|2))
    fi

    if [ $TST_WARN -gt 0 ]; then
        ret=$((ret|4))
    fi

    if [ $TST_CONF -gt 0 ]; then
        ret=$((ret|32))
    fi

    echo
    echo "Summary:"
    echo "passed    $TST_PASS"
    echo "failed    $TST_FAIL"
    echo "broken    $TST_BROK"
    echo "skipped   $TST_CONF"
    echo "warnings  $TST_WARN"

    exit $ret
}

_tst_inc_ret()
{
    case "$1" in
    TPASS) TST_PASS=$((TST_PASS+1));;
    TFAIL) TST_FAIL=$((TST_FAIL+1));;
    TBROK) TST_BROK=$((TST_BROK+1));;
    TWARN) TST_WARN=$((TST_WARN+1));;
    TCONF) TST_CONF=$((TST_CONF+1));;
    TINFO) ;;
        *) tst_brk TBROK "Invalid res type '$1'";;
    esac
}

tst_res()
{
    local res=$1
    shift

    tst_color_enabled
    local color=$?

    TST_COUNT=$(($TST_COUNT+1))

    _tst_inc_ret "$res"
    printf "$TST_ID $TST_COUNT $(date) "
    tst_print_colored $res "$res: "
    echo "$@"
}

tst_brk()
{
    local res=$1
    shift

    if [ "$TST_DO_EXIT" = 1 ]; then
        tst_res TWARN "$@"
        return
    fi

    tst_res "$res" "$@"
    tst_exit
}

tst_judged()
{
    actual_res=$1
    shift
    expect_res=$1
    shift

    comment="$@"
    if [ "$actual_res" == "$expect_res" ]; then
        tst_res TPASS "$comment test pass, expect $expect_res return $actual_res"
    else
        tst_res TFAIL "$comment test fail, expect $expect_res return $actual_res"
    fi
}

tst_judged_fail()
{
    actual_res1=$1
    shift
    expect_res1=$1
    shift
    comment_fail="$@"
    if [ "$actual_res1" != "$expect_res1" ]; then
        tst_res TPASS "$comment_fail test pass, expect $expect_res1 return $actual_res1"
    else
        tst_res TFAIL "$comment_fail test fail, expect $expect_res1 return $actual_res1"
    fi
}

get_product()
{
    echo $(uname -a | awk '{printf $NF}')
}

if [ -z "$TST_TD" ]; then
    _tst_filename=$(basename $0) || \
    tst_brk TCONF "Failed to set TST_TD from \$0 ('$0'), fix it with setting TST_ID before sourcing tst_test.sh"
    TST_ID=${_tst_filename%%.*}
fi
export TST_ID="$TST_ID"
