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
from mininet.topo import SingleSwitchTopo
from mininet.node import OVSSwitch, RemoteController
from functools import partial
from mininet.util import quietRun

if __name__ == '__main__':
    setLogLevel( 'info' )

    info( '*** Installing required software' )
    print quietRun( 'apt-get update' )
    print quietRun( 'apt-get -y install dnsmasq ethtool' )

    info( '*** Creating network\n' )
    print quietRun( 'ovs-vsctl set Open_vSwitch . other_config:vlan-limit={{ .Values.vlanMatchDepth }}' )
    OVSSwitch13 = partial( OVSSwitch, protocols='OpenFlow13' )
    controllerIp = socket.gethostbyname( '{{ .Values.onosOpenflowSvc }}' )
    net = Mininet( topo=SingleSwitchTopo(1),
                   controller=lambda name: RemoteController( name, ip=controllerIp, port=6653 ),
                   switch=OVSSwitch13
    )

    switch = net.switches[ 0 ]
    info( '*** Adding hardware interface eth1 to switch', switch.name, '\n' )
    _intf = Intf( 'eth1', node=switch )

    info( '*** Turning off checksum offloading for eth1\n' )
    print quietRun( 'ethtool -K eth1 tx off rx off' )

    bgphost = net.hosts [ 0 ]
    info( '*** Adding VLAN interface to host\n')
    bgphost.cmd( 'ip link add link h1-eth0 name h1-eth0.222 type vlan proto 802.1Q id 222' )
    bgphost.cmd( 'ip link add link h1-eth0.222 name h1-eth0.222.111 type vlan proto 802.1Q id 111' )
    bgphost.cmd( 'ifconfig h1-eth0.222 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.111 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.111 172.18.0.10/24' )
    bgphost.cmd( 'dnsmasq --dhcp-range=172.18.0.50,172.18.0.150,12h' )

    net.start()
    CLI( net )
    net.stop()
