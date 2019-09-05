#!/usr/bin/python

# Copyright 2017-present Open Networking Foundation
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

import re
import sys
import socket

from mininet.cli import CLI
from mininet.log import setLogLevel, info, error
from mininet.net import Mininet
from mininet.link import Intf
from mininet.topo import Topo, SingleSwitchTopo
from mininet.node import OVSSwitch, Controller, RemoteController
from mininet.nodelib import LinuxBridge
from functools import partial
from mininet.util import quietRun

if __name__ == '__main__':
    setLogLevel( 'info' )

    print quietRun( 'ovs-vsctl set Open_vSwitch . other_config:vlan-limit={{ .Values.vlanMatchDepth }}' )
    OVSSwitch13 = partial( OVSSwitch, protocols='OpenFlow13' )
    controllerIp = socket.gethostbyname( '{{ .Values.onosOpenflowSvc }}' )

    net = Mininet( topo=None )

    info( '*** Adding controllers\n' )
    onos = net.addController( name='onos', controller=RemoteController, ip=controllerIp, port=6653 )

    info( '*** Adding switches\n' )
    s1 = net.addSwitch( name='s1', cls=OVSSwitch13 )
    s2 = net.addSwitch( 's2', cls=LinuxBridge )

    info( '*** Creating hosts\n' )
    h1 = net.addHost( 'h1', ip='10.0.0.1/24')
    h2 = net.addHost( 'h2', ip='10.1.0.2/24')

    # Topology: pon1 - eth1 - s1 - h1 - s2 - h2
    net.addLink( h1, s1 )
    net.addLink( h1, s2 )
    net.addLink( h2, s2 )

{{- range $i, $junk := until (.Values.numOlts|int) -}}
{{- $intf := printf "eth%d" (add $i 1) }}

    info( '*** Adding hardware interface {{ $intf }} to switch s1\n')
    _intf = Intf( '{{ $intf }}', node=s1 )

    info( '*** Turning off checksum offloading for {{ $intf }}\n' )
    print quietRun( 'ethtool -K {{ $intf }} tx off rx off' )
{{- end }}

    info( '*** Adding VLAN interface to host h1\n')
    h1.cmd( 'ifconfig h1-eth1 10.1.0.1/24 up')

    {{- $onucount := .Values.numOnus|int}}
{{- range $i, $junk := until (.Values.numOlts|int) -}}
{{- $stag := add 222 $i }}
{{- range $j, $junk1 := until ($onucount) -}}
{{- $ctag := add 111 $j }}
    h1.cmd( 'ip link add link h1-eth0 name h1-eth0.{{ $stag }} type vlan proto 802.1Q id {{ $stag }}' )
    h1.cmd( 'ip link add link h1-eth0.{{ $stag }} name h1-eth0.{{ $stag }}.{{ $ctag }} type vlan proto 802.1Q id {{ $ctag }}' )
    h1.cmd( 'ifconfig h1-eth0.{{ $stag }} up' )
    h1.cmd( 'ifconfig h1-eth0.{{ $stag }}.{{ $ctag }} up' )
    h1.cmd( 'ifconfig h1-eth0.{{ $stag }}.{{ $ctag }} 172.{{ add $i 18  }}.{{ $j }}.10/24' )
{{- end }}
{{- end }}
    h1.cmd( 'dnsmasq {{ template "mininet.dhcp_range" . }}' )

{{- if .Values.enableMulticast }}
    info( '*** Start multicast routing on h1 and source on h2\n')
    h1.cmd( 'service pimd start' )
    h2.cmd( 'mcjoin -s -i h2-eth0 -t 2 >& /tmp/mcjoin.log &')
{{- end }}

    onos.start()
    s1.start( [onos] )

    net.start()
    CLI( net )
    net.stop()
