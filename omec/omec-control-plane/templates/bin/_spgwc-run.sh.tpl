#!/bin/bash
#
# Copyright 2019-present Open Networking Foundation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

set -xe

mkdir -p /opt/cp/config
cd /opt/cp/config
cp /etc/cp/config/{adc_rules.cfg,cp_config.cfg,interface.cfg,meter_profile.cfg,pcc_rules.cfg,sdf_rules.cfg} .

sed -i "s/CP_ADDR/$POD_IP/g" interface.cfg

. cp_config.cfg
ngic_controlplane $EAL_ARGS -- $APP_ARGS
