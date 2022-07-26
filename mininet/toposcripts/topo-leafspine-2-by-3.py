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

        # Spines
        # gRPC port 50004
        spine1 = self.addSwitch('spine1', cls=StratumBmv2Switch, cpuport=CPU_PORT)
        # gRPC port 50005
        spine2 = self.addSwitch('spine2', cls=StratumBmv2Switch, cpuport=CPU_PORT)

        # Switch Links
        self.addLink(spine1, leaf1)
        self.addLink(spine1, leaf2)
        self.addLink(spine1, leaf3)
        self.addLink(spine2, leaf1)
        self.addLink(spine2, leaf2)
        self.addLink(spine2, leaf3)

        # IPv4 hosts attached to leaf 1
        h1a = self.addHost('h1a', cls=IPv4Host, mac="00:00:00:00:00:1A",
                           ip='172.16.1.1/24', gw='172.16.1.254')
        h1b = self.addHost('h1b', cls=IPv4Host, mac="00:00:00:00:00:1B",
                           ip='172.16.1.2/24', gw='172.16.1.254')
        h1c = self.addHost('h1c', cls=TaggedIPv4Host, mac="00:00:00:00:00:1C",
                           ip='172.16.1.3/24', gw='172.16.1.254', vlan=100)
        h2a = self.addHost('h2a', cls=TaggedIPv4Host, mac="00:00:00:00:00:2A",
                          ip='172.16.2.1/24', gw='172.16.2.254', vlan=200)
        h2b = self.addHost('h2b', cls=TaggedIPv4Host, mac="00:00:00:00:00:2B",
                          ip='172.16.2.2/24', gw='172.16.2.254', vlan=200)
        h2c = self.addHost('h2c', cls=IPv4Host, mac="00:00:00:00:00:2C",
                          ip='172.16.2.3/24', gw='172.16.2.254')
        h3a = self.addHost('h3a', cls=TaggedIPv4Host, mac="00:00:00:00:00:3A",
                           ip='172.16.3.1/24', gw='172.16.3.254', vlan=300)
        h3b = self.addHost('h3b', cls=IPv4Host, mac="00:00:00:00:00:3B",
                           ip='172.16.3.2/24', gw='172.16.3.254')
        h3c = self.addHost('h3c', cls=IPv4Host, mac="00:00:00:00:00:3C",
                           ip='172.16.3.3/24', gw='172.16.3.254')
        self.addLink(h1a, leaf1)  # port 3
        self.addLink(h1b, leaf1)  # port 4
        self.addLink(h1c, leaf1)  # port 5
        self.addLink(h2a, leaf1)  # port 6
        self.addLink(h2b, leaf1)  # port 7
        self.addLink(h2c, leaf1)  # port 8
        self.addLink(h3a, leaf1)  # port 9
        self.addLink(h3b, leaf1)  # port 10
        self.addLink(h3c, leaf1)  # port 11

        # IPv4 hosts attached to leaf 2
        h4a = self.addHost('h1a', cls=IPv4Host, mac="00:00:00:00:00:4A",
                           ip='172.16.4.1/24', gw='172.16.4.254')
        h4b = self.addHost('h1b', cls=IPv4Host, mac="00:00:00:00:00:4B",
                           ip='172.16.4.2/24', gw='172.16.4.254')
        h4c = self.addHost('h1c', cls=TaggedIPv4Host, mac="00:00:00:00:00:4C",
                           ip='172.16.4.3/24', gw='172.16.4.254', vlan=400)
        h5a = self.addHost('h2a', cls=TaggedIPv4Host, mac="00:00:00:00:00:5A",
                          ip='172.16.5.1/24', gw='172.16.5.254', vlan=500)
        h5b = self.addHost('h2b', cls=TaggedIPv4Host, mac="00:00:00:00:00:5B",
                          ip='172.16.5.2/24', gw='172.16.5.254', vlan=500)
        h5c = self.addHost('h2c', cls=IPv4Host, mac="00:00:00:00:00:5C",
                          ip='172.16.5.3/24', gw='172.16.5.254')
        h6a = self.addHost('h3a', cls=TaggedIPv4Host, mac="00:00:00:00:00:6A",
                           ip='172.16.6.1/24', gw='172.16.6.254', vlan=600)
        h6b = self.addHost('h3b', cls=IPv4Host, mac="00:00:00:00:00:6B",
                           ip='172.16.6.2/24', gw='172.16.6.254')
        h6c = self.addHost('h3c', cls=IPv4Host, mac="00:00:00:00:00:6C",
                           ip='172.16.6.3/24', gw='172.16.6.254')
        self.addLink(h4a, leaf2)  # port 3
        self.addLink(h4b, leaf2)  # port 4
        self.addLink(h4c, leaf2)  # port 5
        self.addLink(h5a, leaf2)  # port 6
        self.addLink(h5b, leaf2)  # port 7
        self.addLink(h5c, leaf2)  # port 8
        self.addLink(h6a, leaf2)  # port 9
        self.addLink(h6b, leaf2)  # port 10
        self.addLink(h6c, leaf2)  # port 11

        # IPv4 hosts attached to leaf 2
        h7a = self.addHost('h1a', cls=IPv4Host, mac="00:00:00:00:00:7A",
                           ip='172.16.7.1/24', gw='172.16.7.254')
        h7b = self.addHost('h1b', cls=IPv4Host, mac="00:00:00:00:00:7B",
                           ip='172.16.7.2/24', gw='172.16.7.254')
        h7c = self.addHost('h1c', cls=TaggedIPv4Host, mac="00:00:00:00:00:7C",
                           ip='172.16.7.3/24', gw='172.16.7.254', vlan=700)
        h8a = self.addHost('h2a', cls=TaggedIPv4Host, mac="00:00:00:00:00:8A",
                          ip='172.16.8.1/24', gw='172.16.8.254', vlan=800)
        h8b = self.addHost('h2b', cls=TaggedIPv4Host, mac="00:00:00:00:00:8B",
                          ip='172.16.8.2/24', gw='172.16.8.254', vlan=800)
        h8c = self.addHost('h2c', cls=IPv4Host, mac="00:00:00:00:00:8C",
                          ip='172.16.8.3/24', gw='172.16.8.254')
        h9a = self.addHost('h3a', cls=TaggedIPv4Host, mac="00:00:00:00:00:9A",
                           ip='172.16.9.1/24', gw='172.16.9.254', vlan=900)
        h9b = self.addHost('h3b', cls=IPv4Host, mac="00:00:00:00:00:9B",
                           ip='172.16.9.2/24', gw='172.16.9.254')
        h9c = self.addHost('h3c', cls=IPv4Host, mac="00:00:00:00:00:9C",
                           ip='172.16.9.3/24', gw='172.16.9.254')
        self.addLink(h7a, leaf3)  # port 3
        self.addLink(h7b, leaf3)  # port 4
        self.addLink(h7c, leaf3)  # port 5
        self.addLink(h8a, leaf3)  # port 6
        self.addLink(h8b, leaf3)  # port 7
        self.addLink(h8c, leaf3)  # port 8
        self.addLink(h9a, leaf3)  # port 9
        self.addLink(h9b, leaf3)  # port 10
        self.addLink(h9c, leaf3)  # port 11


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
