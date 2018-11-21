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

    bgphost.cmd( 'ifconfig h1-eth0.222 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.111 up' )
    bgphost.cmd( 'ifconfig h1-eth0.222.111 172.18.0.10/24' )

    # for BBSim
    bgphost.cmd( 'ip link add link h1-eth0 name h1-eth0.999 type vlan id 999' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.900 type vlan id 900' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.901 type vlan id 901' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.902 type vlan id 902' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.903 type vlan id 903' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.904 type vlan id 904' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.905 type vlan id 905' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.906 type vlan id 906' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.907 type vlan id 907' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.908 type vlan id 908' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.909 type vlan id 909' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.910 type vlan id 910' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.911 type vlan id 911' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.912 type vlan id 912' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.913 type vlan id 913' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.914 type vlan id 914' )
    bgphost.cmd( 'ip link add link h1-eth0.999 name h1-eth0.999.915 type vlan id 915' )

    bgphost.cmd( 'ifconfig h1-eth0.999 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.900 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.901 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.902 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.903 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.904 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.905 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.906 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.907 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.908 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.909 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.910 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.911 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.912 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.913 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.914 up' )
    bgphost.cmd( 'ifconfig h1-eth0.999.915 up' )

    bgphost.cmd( 'ifconfig h1-eth0.999.900 172.18.0.20/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.901 172.18.0.21/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.902 172.18.0.22/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.903 172.18.0.23/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.904 172.18.0.24/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.905 172.18.0.25/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.906 172.18.0.26/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.907 172.18.0.27/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.907 172.18.0.27/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.908 172.18.0.28/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.909 172.18.0.29/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.910 172.18.0.30/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.911 172.18.0.31/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.912 172.18.0.32/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.913 172.18.0.33/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.914 172.18.0.34/24' )
    bgphost.cmd( 'ifconfig h1-eth0.999.915 172.18.0.35/24' )

    bgphost.cmd( 'dnsmasq --dhcp-range=172.18.0.50,172.18.0.150,12h' )

    net.start()
    CLI( net )
    net.stop()
