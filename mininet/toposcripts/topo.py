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

    info( '*** Installing required software\n' )
    print quietRun( 'apt-get update' )
    print quietRun( 'apt-get -y install dnsmasq ethtool wget pimd bridge-utils' )
    print quietRun( 'wget https://github.com/troglobit/mcjoin/releases/download/v2.4/mcjoin_2.4_amd64.deb' )
    print quietRun( 'dpkg -i mcjoin_2.4_amd64.deb' )

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

    info( '*** Adding hardware interface eth1 to switch %s\n' % s1.name)
    _intf = Intf( 'eth1', node=s1 )

    info( '*** Turning off checksum offloading for eth1\n' )
    print quietRun( 'ethtool -K eth1 tx off rx off' )

    info( '*** Adding VLAN interface to host %s\n' % h1.name)
    base = "%s-eth0" % h1.name
    h1.cmd( 'ifconfig %s-eth1 10.1.0.1/24 up' % h1.name)
    h1.cmd( 'ip link add link %s name %s.222 type vlan proto 802.1Q id 222' % (base, base))
    h1.cmd( 'ip link add link %s.222 name %s.222.111 type vlan proto 802.1Q id 111' % (base, base))
    h1.cmd( 'ifconfig %s.222 up' % base)
    h1.cmd( 'ifconfig %s.222.111 up' % base)
    h1.cmd( 'ifconfig %s.222.111 172.18.0.10/24' % base)
    h1.cmd( 'dnsmasq --dhcp-range=172.18.0.50,172.18.0.150,12h' )

    onos.start()
    s1.start( [onos] )

    net.start()
    CLI( net )
    net.stop()
