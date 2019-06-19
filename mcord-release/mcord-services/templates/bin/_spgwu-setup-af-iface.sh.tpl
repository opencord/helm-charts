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

UL_IFACE="{{- .Values.spgwu.conf.dp.s1u_af_dev -}}"
DL_IFACE="{{- .Values.spgwu.conf.dp.sgi_af_dev -}}"

if ! ip link show $UL_IFACE; then
    s1u_mac=$(ip addr show dev s1u-net | awk '$1=="link/ether"{print $2}')
    ip link add $UL_IFACE type veth peer name l_$UL_IFACE
    ip link set $UL_IFACE up
    ip link set l_$UL_IFACE up
    ip link set dev $UL_IFACE address $s1u_mac
fi
if ! ip link show $DL_IFACE; then
    sgi_mac=$(ip addr show dev sgi-net | awk '$1=="link/ether"{print $2}')
    ip link add $DL_IFACE type veth peer name l_$DL_IFACE
    ip link set $DL_IFACE up
    ip link set l_$DL_IFACE up
    ip link set dev $DL_IFACE address $sgi_mac
fi

if ! ip addr show $UL_IFACE | grep inet; then
    s1u_ip=$(ip addr show s1u-net | grep inet | grep -v inet6 | awk '{print $2}')
    ip addr add $s1u_ip dev $UL_IFACE
fi
if ! ip addr show $DL_IFACE | grep inet; then
    sgi_ip=$(ip addr show sgi-net | grep inet | grep -v inet6 | awk '{print $2}')
    ip addr add $sgi_ip dev $DL_IFACE
fi

ip a
