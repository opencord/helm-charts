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

COMMAND="${@:-start}"
LTE_IF=oip1

function wait_enb() {
  ENB_POD={{ tuple "enb" "fqdn" . | include "oaisim.endpoint_lookup" | quote }}
  until nslookup $ENB_POD; do echo "waiting for ENB"; sleep 2; done;

  ENB_IP=$(dig +short $ENB_POD)
  sed -i "s/NFAPI_REMOTE_ADDRESS/\"$ENB_IP\"/g" /etc/oaisim/ue/nfapi.conf
  sed -i "s/NFAPI_LOCAL_ADDRESS/\"$UE_LOCAL_IP\"/g" /etc/oaisim/ue/nfapi.conf
}

function init_lte_rt() {
  echo "bring up $LTE_IF interface for UE"
  ifconfig $LTE_IF up

  ip route flush cache
  grep lte /etc/iproute2/rt_tables > /dev/null
  if [ $? -ne 0 ]; then
    echo "200 lte " >> /etc/iproute2/rt_tables
  fi
  ip rule add fwmark 1 table lte
  ip route add default dev $LTE_IF table lte
}

function start () {
  cp /opt/oaisim/ue/config/nfapi.conf /etc/oaisim/ue/nfapi.conf
  cd /openairinterface5g/cmake_targets

  # copy usim data to build dir
  cp /etc/oaisim/ue/.u* .
  cp /etc/oaisim/ue/.u* ./lte_build_oai/build/

  wait_enb
  init_lte_rt
  cat /etc/oaisim/ue/nfapi.conf
  exec ./lte_build_oai/build/lte-uesoftmodem -O /etc/oaisim/ue/nfapi.conf --L2-emul 3 --num-ues 1 --nums_ue_thread 1
}

function stop () {
  kill -TERM 1
}

$COMMAND
