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
    """2x2 fabric topology with IPv4 hosts"""

    def __init__(self, *args, **kwargs):
        Topo.__init__(self, *args, **kwargs)

        # Leaves
        # gRPC port 50001
        leaf1 = self.addSwitch('leaf1', cls=StratumBmv2Switch, cpuport=CPU_PORT)
        # gRPC port 50002
        leaf2 = self.addSwitch('leaf2', cls=StratumBmv2Switch, cpuport=CPU_PORT)

        # Spines
        # gRPC port 50003
        spine1 = self.addSwitch('spine1', cls=StratumBmv2Switch, cpuport=CPU_PORT)
        # gRPC port 50004
        spine2 = self.addSwitch('spine2', cls=StratumBmv2Switch, cpuport=CPU_PORT)

        # Switch Links
        self.addLink(spine1, leaf1)
        self.addLink(spine1, leaf2)
        self.addLink(spine2, leaf1)
        self.addLink(spine2, leaf2)

        # IPv4 hosts attached to leaf 1
        h1a = self.addHost('h1a', cls=IPv4Host, mac="00:00:00:00:00:1A",
                           ip='172.16.1.1/24', gw='172.16.1.254')
        h1b = self.addHost('h1b', cls=IPv4Host, mac="00:00:00:00:00:1B",
                           ip='172.16.1.2/24', gw='172.16.1.254')
        hVa = self.addHost('hVa', cls=IPv4Host, mac="AA:BB:CC:DD:EE:FE",
                           ip='172.16.1.101/24', gw='172.16.1.254')
        hVb = self.addHost('hVb', cls=TaggedIPv4Host, mac="AA:BB:CC:DD:EE:FF",
                           ip='172.16.1.102/24', gw='172.16.1.254', vlan=15)
        hVc = self.addHost('hVc', cls=IPv4Host, mac="AA:BB:CC:DD:EE:EE",
                           ip='172.16.1.103/24', gw='172.16.1.254')
        hVd = self.addHost('hVd', cls=TaggedIPv4Host, mac="AA:BB:CC:DD:EE:EF",
                           ip='172.16.1.104/24', gw='172.16.1.254', vlan=15)
        self.addLink(h1a, leaf1)  # port 3
        self.addLink(h1b, leaf1)  # port 4
        self.addLink(hVa, leaf1)  # port 5
        self.addLink(hVb, leaf1)  # port 6
        self.addLink(hVc, leaf1)  # port 7
        self.addLink(hVd, leaf1)  # port 8

        # IPv4 hosts attached to leaf 2
        h3 = self.addHost('h3', cls=TaggedIPv4Host, mac="00:00:00:00:00:30",
                          ip='172.16.3.1/24', gw='172.16.3.254', vlan=300)
        h4 = self.addHost('h4', cls=IPv4Host, mac="00:00:00:00:00:40",
                          ip='172.16.4.1/24', gw='172.16.4.254')
        self.addLink(h3, leaf2)  # port 3
        self.addLink(h4, leaf2)  # port 4


def main():
    net = Mininet(topo=TutorialTopo(), controller=None)
    net.start()
    net.staticArp()
    CLI(net)
    net.stop()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Mininet topology script for 2x2 fabric with stratum_bmv2 and IPv4 hosts')
    args = parser.parse_args()
    setLogLevel('info')

    main()
