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

LTE_IF=oip1

ip link set $LTE_IF up
if ! grep -q lte /etc/iproute2/rt_tables; then
  echo "200 lte " >> /etc/iproute2/rt_tables
fi

ip rule add fwmark 1 table lte
ip route add default dev $LTE_IF table lte || true

# enable inet6 for lo interface
# lte-uesoftmodem uses AF_INET6 for UDP socket
echo 0 > /proc/sys/net/ipv6/conf/lo/disable_ipv6
