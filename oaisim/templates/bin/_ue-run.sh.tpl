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

function start () {
  cd /openairinterface5g/cmake_targets
  cp /opt/oaisim/ue/config/nfapi.conf /etc/oaisim/ue/nfapi.conf

  # Copy USIM data
  cp /etc/oaisim/ue/.u* .
  cp /etc/oaisim/ue/.u* ./lte_build_oai/build/

  exec ./lte_build_oai/build/lte-uesoftmodem -O /etc/oaisim/ue/nfapi.conf --L2-emul 3 --num-ues 1 --nums_ue_thread 1
}

function stop () {
  # TODO: clean up ip tables and rules
  kill -TERM 1
}

$COMMAND
