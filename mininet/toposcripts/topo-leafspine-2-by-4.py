#!/usr/bin/python

# SPDX-FileCopyrightText: 2022-present Intel Corporation
# SPDX-License-Identifier: Apache-2.0

import argparse

from mininet.cli import CLI
from mininet.log import setLogLevel
from mininet.net import Mininet
from mininet.topo import Topo
from stratum import StratumBmv2Switch

from mn_lib import IPv4Host
from mn_lib import TaggedIPv4Host

CPU_PORT = 255


class TutorialTopo(Topo):
    """2x4 fabric topology with IPv4 hosts"""

    def __init__(self, *args, **kwargs):
        Topo.__init__(self, *args, **kwargs)

        # Leaves
        # gRPC port 50001
        leaf1 = self.addSwitch('leaf1', cls=StratumBmv2Switch, cpuport=CPU_PORT)
        # gRPC port 50002
        leaf2 = self.addSwitch('leaf2', cls=StratumBmv2Switch, cpuport=CPU_PORT)
        # gRPC port 50003
        leaf3 = self.addSwitch('leaf3', cls=StratumBmv2Switch, cpuport=CPU_PORT)
        # gRPC port 50004
        leaf4 = self.addSwitch('leaf4', cls=StratumBmv2Switch, cpuport=CPU_PORT)

        # Spines
        # gRPC port 50005
        spine1 = self.addSwitch('spine1', cls=StratumBmv2Switch, cpuport=CPU_PORT)
        # gRPC port 50006
        spine2 = self.addSwitch('spine2', cls=StratumBmv2Switch, cpuport=CPU_PORT)

        # Switch Links
        self.addLink(spine1, leaf1)
        self.addLink(spine1, leaf2)
        self.addLink(spine1, leaf3)
        self.addLink(spine1, leaf4)
        self.addLink(spine2, leaf1)
        self.addLink(spine2, leaf2)
        self.addLink(spine2, leaf3)
        self.addLink(spine2, leaf4)

        # IPv4 hosts attached to leaf 1
        h1a = self.addHost('h1a', cls=IPv4Host, mac="00:00:00:00:00:1A",
                           ip='172.16.1.1/24', gw='172.16.1.254')
        h1b = self.addHost('h1b', cls=IPv4Host, mac="00:00:00:00:00:1B",
                           ip='172.16.1.2/24', gw='172.16.1.254')
        h1c = self.addHost('h1c', cls=TaggedIPv4Host, mac="00:00:00:00:00:1C",
                           ip='172.16.1.3/24', gw='172.16.1.254', vlan=100)
        h2 = self.addHost('h2', cls=TaggedIPv4Host, mac="00:00:00:00:00:20",
                          ip='172.16.2.1/24', gw='172.16.2.254', vlan=200)
        self.addLink(h1a, leaf1)  # port 3
        self.addLink(h1b, leaf1)  # port 4
        self.addLink(h1c, leaf1)  # port 5
        self.addLink(h2, leaf1)  # port 6

        # IPv4 hosts attached to leaf 2
        h3 = self.addHost('h3', cls=TaggedIPv4Host, mac="00:00:00:00:00:30",
                          ip='172.16.3.1/24', gw='172.16.3.254', vlan=300)
        h4 = self.addHost('h4', cls=IPv4Host, mac="00:00:00:00:00:40",
                          ip='172.16.4.1/24', gw='172.16.4.254')
        self.addLink(h3, leaf2)  # port 3
        self.addLink(h4, leaf2)  # port 4

        # Emulated gNodeB (5G base station) attached to leaf 1
        gnb = self.addHost('gnb', cls=IPv4Host, mac='00:00:00:00:99:00',
                           ip='172.16.1.99/24', gw='172.16.1.254')
        self.addLink(gnb, leaf1)  # port 7

        # IPv4 hosts attached to leaf 3
        h2b = self.addHost('h2b', cls=TaggedIPv4Host, mac="00:00:00:00:00:2B",
                           ip='172.16.5.1/24', gw='172.16.5.254', vlan=500)
        h1d = self.addHost('h1d', cls=TaggedIPv4Host, mac="00:00:00:00:00:1D",
                           ip='172.16.6.1/24', gw='172.16.6.254', vlan=600)
        h3b = self.addHost('h3b', cls=IPv4Host, mac="00:00:00:00:00:3B",
                           ip='172.16.5.2/24', gw='172.16.5.254')
        self.addLink(h2b, leaf3)  # port 3
        self.addLink(h1d, leaf3)  # port 4
        self.addLink(h3b, leaf3)  # port 5

        # IPv4 hosts attached to leaf 4
        h4b = self.addHost('h4b', cls=TaggedIPv4Host, mac="00:00:00:00:00:4B",
                           ip='172.16.7.1/24', gw='172.16.7.254', vlan=700)
        h3c = self.addHost('h3c', cls=IPv4Host, mac="00:00:00:00:00:3C",
                           ip='172.16.7.2/24', gw='172.16.7.254')
        self.addLink(h4b, leaf4)  # port 3
        self.addLink(h3c, leaf4)  # port 4


def main():
    net = Mininet(topo=TutorialTopo(), controller=None)
    net.start()
    CLI(net)
    net.stop()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Mininet topology script for 2x2 fabric with stratum_bmv2 and IPv4 hosts')
    args = parser.parse_args()
    setLogLevel('info')

    main()
