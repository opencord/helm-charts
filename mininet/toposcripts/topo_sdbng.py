#!/usr/bin/python

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

from mininet.cli import CLI
from mininet.log import setLogLevel, info, error
from mininet.net import Mininet
from mininet.link import Intf
from mininet.nodelib import LinuxBridge
from stratum import StratumBmv2Switch
from mininet.util import quietRun

CPU_PORT = 255

if __name__ == '__main__':
    setLogLevel( 'info' )

    net = Mininet( topo=None )

    info( '*** Adding switches\n' )
    agg1 = net.addSwitch( name='agg1', cls=StratumBmv2Switch, cpuport=CPU_PORT)
    # FIXME: enable multicast
    # s2 = net.addSwitch( 's2', cls=LinuxBridge )

    info( '*** Creating hosts\n' )
    h1 = net.addHost( 'h1' ) # PPPoE Server
    h2 = net.addHost( 'h2', ip='10.10.10.1/24', mac="00:66:77:88:99:AA") # Upstream
    # FIXME: enable multicast
    # h3 = net.addHost( 'h3')

    # Topology: pon1 - eth1 - agg1 - h2 - s2 - h3
    #                          |
    #                          h1
    net.addLink( h1, agg1 )
    net.addLink( h2, agg1 )
    # FIXME: enable multicast
    # net.addLink( h2, s2 )
    # net.addLink( h3, s2 )

{{- range $i, $junk := until (.Values.numOlts|int) -}}
{{- $intf := printf "eth%d" (add $i 1) }}

    info( '*** Adding hardware interface {{ $intf }} to switch agg1\n')
    _intf = Intf( '{{ $intf }}', node=agg1 )

    info( '*** Turning off checksum offloading for {{ $intf }}\n' )
    print quietRun( 'ethtool -K {{ $intf }} tx off rx off' )
{{- end }}


# FIXME: enable multicast
# {{- if .Values.enableMulticast }}
#     info( '*** Start multicast routing on h1 and source on h2\n')
#     h2.cmd( 'service pimd start' )
#     h3.cmd( 'mcjoin -s -i h2-eth0 -t 2 >& /tmp/mcjoin.log &')
# {{- end }}

    net.start()
    info( '*** Starting PPPoE Server')
    h1.cmd( 'echo 10.255.255.100-250 > /iptoassign')
    h1.cmd( 'pppoe-server -I h1-eth0 -L 10.255.255.1 -p /iptoassign -O /pppoe-options')
    info( '*** Setting route back to access network')
    h2.cmd( 'ip route add 10.255.255.0/24 via 10.10.10.254')
    CLI( net )
    net.stop()
