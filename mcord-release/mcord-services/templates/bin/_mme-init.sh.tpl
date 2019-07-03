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

cp /opt/mme/config/config.json /opt/mme/config/shared/config.json
cd /opt/mme/config/shared

# Set local IP address for s1ap and s11 networks to the config
jq --arg MME_LOCAL_IP "$MME_LOCAL_IP" '.mme.ip_addr=$MME_LOCAL_IP' config.json > config.tmp && mv config.tmp config.json
jq --arg MME_LOCAL_IP "$MME_LOCAL_IP" '.s1ap.s1ap_local_addr=$MME_LOCAL_IP' config.json > config.tmp && mv config.tmp config.json
jq --arg MME_LOCAL_IP "$MME_LOCAL_IP" '.s11.egtp_local_addr=$MME_LOCAL_IP' config.json > config.tmp && mv config.tmp config.json

# Set SPGW-C address to the config
SPGWC_POD={{ tuple "spgwc" "identity" . | include "mcord-services.endpoint_lookup" | quote }}
SPGWC_ADDR=$(dig +short $SPGWC_POD)
jq --arg SPGWC_ADDR "$SPGWC_ADDR" '.s11.sgw_addr //= $SPGWC_ADDR' config.json > config.tmp && mv config.tmp config.json
jq --arg SPGWC_ADDR "$SPGWC_ADDR" '.s11.pgw_addr //= $SPGWC_ADDR' config.json > config.tmp && mv config.tmp config.json

# Add additional redundant keys - should be fixed in openmme
HSS_TYPE=$(jq -r '.s6a.host_type' config.json)
HSS_HOST=$(jq -r '.s6a.host' config.json)
jq --arg HSS_TYPE "$HSS_TYPE" '.s6a.hss_type=$HSS_TYPE' config.json > config.tmp && mv config.tmp config.json
jq --arg HSS_HOST "$HSS_HOST" '.s6a.host_name=$HSS_HOST' config.json > config.tmp && mv config.tmp config.json

# Copy the final configs for each applications
cp /opt/mme/config/shared/config.json /opt/mme/config/shared/mme.json
cp /opt/mme/config/shared/config.json /opt/mme/config/shared/s11.json
cp /opt/mme/config/shared/config.json /opt/mme/config/shared/s1ap.json
cp /opt/mme/config/shared/config.json /opt/mme/config/shared/s6a.json
cp /opt/mme/config/s6a_fd.conf /opt/mme/config/shared/s6a_fd.conf

# Generate certs
MME_IDENTITY={{ tuple "mme" "identity" . | include "mcord-services.endpoint_lookup" | quote }};
DIAMETER_HOST=$(echo $MME_IDENTITY | cut -d'.' -f1)
DIAMETER_REALM={{ tuple "mme" "realm" . | include "mcord-services.endpoint_lookup" | quote }};

cp /openmme/target/conf/make_certs.sh /opt/mme/config/shared/make_certs.sh
cd /opt/mme/config/shared
./make_certs.sh $DIAMETER_HOST $DIAMETER_REALM
