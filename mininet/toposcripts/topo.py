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
    OVSSwitch13 = partial( OVSSwitch, protocols='OpenFlow13' )
    controllerIp = socket.gethostbyname( 'onos-openflow.default.svc.cluster.local' )
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
    bgphost.cmd( 'ip link add link h1-eth0 name h1-eth0.222 type vlan id 222' )
    bgphost.cmd( 'ip link add link h1-eth0.222 name h1-eth0.222.111 type vlan id 111' )
    # for BBSim
    bgphost.cmd( 'ip link add link h1-eth0.222 name h1-eth0.222.900 type vlan id 900' )
    bgphost.cmd( 'ip link add link h1-eth0.222 name h1-eth0.222.901 type vlan id 901' )
    bgphost.cmd( 'ip link add link h1-eth0.222 name h1-eth0.222.902 type vlan id 902' )
    bgphost.cmd( 'ip link add link h1-eth0.222 name h1-eth0.222.903 type vlan id 903' )
    bgphost.cmd( 'ip link add link h1-eth0.222 name h1-eth0.222.904 type vlan id 904' )
    bgphost.cmd( 'ip link add link h1-eth0.222 name h1-eth0.222.905 type vlan id 905' )
    bgphost.cmd( 'ip link add link h1-eth0.222 name h1-eth0.222.906 type vlan id 906' )
    bgphost.cmd( 'ip link add link h1-eth0.222 name h1-eth0.222.907 type vlan id 907' )
    bgphost.cmd( 'ip link add link h1-eth0.222 name h1-eth0.222.908 type vlan id 908' )

    bgphost.cmd( 'ifconfig h1-eth0.222 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.111 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.900 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.901 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.902 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.903 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.904 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.905 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.906 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.907 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.908 up' )

    bgphost.cmd( 'ifconfig h1-eth0.222.111 172.18.0.10/24' )
    bgphost.cmd( 'ifconfig h1-eth0.222.900 172.18.0.20/24' )
    bgphost.cmd( 'ifconfig h1-eth0.222.901 172.18.0.21/24' )
    bgphost.cmd( 'ifconfig h1-eth0.222.902 172.18.0.22/24' )
    bgphost.cmd( 'ifconfig h1-eth0.222.903 172.18.0.23/24' )
    bgphost.cmd( 'ifconfig h1-eth0.222.904 172.18.0.24/24' )
    bgphost.cmd( 'ifconfig h1-eth0.222.905 172.18.0.25/24' )
    bgphost.cmd( 'ifconfig h1-eth0.222.906 172.18.0.26/24' )
    bgphost.cmd( 'ifconfig h1-eth0.222.907 172.18.0.27/24' )
    bgphost.cmd( 'ifconfig h1-eth0.222.907 172.18.0.27/24' )
    bgphost.cmd( 'ifconfig h1-eth0.222.908 172.18.0.28/24' )

    bgphost.cmd( 'dnsmasq --dhcp-range=172.18.0.50,172.18.0.150,12h' )

    net.start()
    CLI( net )
    net.stop()
