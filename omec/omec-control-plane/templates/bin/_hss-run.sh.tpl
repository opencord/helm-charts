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

set -ex

CONF_DIR="/opt/c3po/hss/conf"
LOGS_DIR="/opt/c3po/hss/logs"
mkdir -p $CONF_DIR $LOGS_DIR

cp /etc/hss/conf/{acl.conf,hss.json,hss.conf,oss.json} $CONF_DIR
cat $CONF_DIR/{hss.json,hss.conf}

cd $CONF_DIR
make_certs.sh {{ tuple "hss" "host" . | include "omec-control-plane.diameter_endpoint" }} {{ tuple "hss" "realm" . | include "omec-control-plane.diameter_endpoint" }}

cd ..
hss -j $CONF_DIR/hss.json
