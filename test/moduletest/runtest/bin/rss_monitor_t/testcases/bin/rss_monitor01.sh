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
# File: rss_monitor01.sh
#
# Description: Verify /proc/pid/rss take effect
#
# Authors:     Liu Ke - liuke94@huawei.com
#
# History:     Sep 20 2022 - init scripts
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

       tst_res TINFO "Start to verify rss ."
       flag=0
       while (($flag < 1))
       do
               pid=$(ps -ef | grep com.ohos.systemui | awk 'NR==1 {print $2}')
               rss=$(cat /proc/$pid/rss | awk -F ':' '{print$2}'| awk '{print$1}')
               statusVMRss=$(cat /proc/$pid/status | grep VmRSS | awk -F ':' '{print$2}' | awk '{print$1}')
               if [ "$rss"x = "$statusVMRss"x ]; then
                       tst_res TPASS "rss info correct."
                       flag=1
               else
                       flag=0
                       fi
       done


}

do_clean()
{

}

do_setup
do_test
do_clean
tst_exit
