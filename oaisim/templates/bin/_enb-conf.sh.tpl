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

cp /opt/oaisim/enb/config/nfapi.conf /etc/oaisim/enb/nfapi.conf

# TODO: set mme ip address
#MME_IP_ADDRESS

S1_MME_IFACE={{ .Values.conf.enb.networks.s1_mme.interface }}
S1_MME_IP=$(ip addr show $S1_MME_IFACE | grep inet | grep -v inet6 | awk '{print $2}' | cut -d'/' -f1)
sed -i "s/S1_MME_IP_ADDRESS/\"$S1_MME_IP\"/g" /etc/oaisim/enb/nfapi.conf 

S1U_IFACE={{ .Values.conf.enb.networks.s1u.interface }}
S1U_IP=$(ip addr show $S1U_IFACE | grep inet | grep -v inet6 | awk '{print $2}' | cut -d'/' -f1)
sed -i "s/S1U_IP_ADDRESS/\"$S1U_IP\"/g" /etc/oaisim/enb/nfapi.conf

sed -i "s/X2C_IP_ADDRESS/\"$ENB_LOCAL_IP\"/g" /etc/oaisim/enb/nfapi.conf 

# Wait UE POD is up
UE_POD={{ tuple "ue" "fqdn" . | include "oaisim.endpoint_lookup" | quote }}
until nslookup $UE_POD; do echo "waiting for UE"; sleep 2; done;
UE_IP=$(dig +short $UE_POD)

sed -i "s/NFAPI_REMOTE_ADDRESS/\"$UE_IP\"/g" /etc/oaisim/enb/nfapi.conf
sed -i "s/NFAPI_LOCAL_ADDRESS/\"$ENB_LOCAL_IP\"/g" /etc/oaisim/enb/nfapi.conf
