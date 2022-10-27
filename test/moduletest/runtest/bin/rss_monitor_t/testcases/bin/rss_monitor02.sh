#!/bin/sh
################################################################################
#
# Copyright (C) 2022 Huawei Device Co., Ltd.
# SPDX-License-Identifier: GPL-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
################################################################################
# File: rss_monitor02.sh
#
# Description: Verify /proc/pid/rss_threshold default value
#
# Authors:     Liu Ke - liuke94@huawei.com
#
# History:     Oct 27 2022 - init scripts
#
################################################################################
source tst_oh.sh

do_setup()
{
	zcat /proc/config.gz | grep CONFIG_RSS_THRESHOLD=y || tst_res TCONF "CONFIG_RSS_THRESHOLD=y not satisfied!"
}

do_test()
{
       local ret=0
       tst_res TINFO "Start to verify rss_threshold default value ."
       pid=$(ps -ef | grep com.ohos.systemui | awk 'NR==1 {print $2}')
       value=$(cat /proc/$pid/rss_threshold | awk -F ':' '{print$2}'| awk '{print$1}')
       echo $value
       if [ "$value"x = "0"x ]; then
               tst_res TPASS "rss_threshold default value correct."
        else
               tst_res TFAIL "rss_threshold default value incorrect."
               ((ret++))
        fi


}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit
