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
    """Single leaf switch with two hosts attached"""

    def __init__(self, *args, **kwargs):
        Topo.__init__(self, *args, **kwargs)

        # Leaves
        # gRPC port 50001
        leaf1 = self.addSwitch('leaf1', cls=StratumBmv2Switch, cpuport=CPU_PORT)

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
        self.addLink(h1a, leaf1)  # port 1
        self.addLink(h1b, leaf1)  # port 2
        self.addLink(hVa, leaf1)  # port 3
        self.addLink(hVb, leaf1)  # port 4
        self.addLink(hVc, leaf1)  # port 5
        self.addLink(hVd, leaf1)  # port 6


def main():
    net = Mininet(topo=TutorialTopo(), controller=None)
    net.start()
    net.staticArp()
    CLI(net)
    net.stop()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description='Mininet topology script for single leaf having two hosts with stratum_bmv2')
    args = parser.parse_args()
    setLogLevel('info')

    main()
