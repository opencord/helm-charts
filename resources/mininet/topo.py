#!/usr/bin/python

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
    bgphost.cmd( 'dnsmasq --dhcp-range=172.18.0.50,172.18.0.150,12h' )
    
    net.start()
    CLI( net )
    net.stop()
