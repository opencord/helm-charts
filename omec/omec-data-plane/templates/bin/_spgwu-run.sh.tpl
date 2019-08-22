#!/bin/bash
#
# Copyright 2019-present Open Networking Foundation
# Copyright 2019 Intel Corporation
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

set -ex

mkdir -p /opt/dp/config
cd /opt/dp/config
cp /etc/dp/config/{cdr.cfg,dp_config.cfg,interface.cfg} .

sed -i "s/DP_ADDR/$POD_IP/g" interface.cfg

source dp_config.cfg
ngic_dataplane $EAL_ARGS -- $APP_ARGS
