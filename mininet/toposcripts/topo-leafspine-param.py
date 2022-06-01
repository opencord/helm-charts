#!/usr/bin/python

# SPDX-FileCopyrightText: 2022-present Intel Corporation
# SPDX-License-Identifier: Apache-2.0

import argparse

from mininet.cli import CLI
from mininet.log import setLogLevel, info
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

        spines = []
        leaves = []
{{- range $i, $junk := until (.Values.numLeaves|int) -}}
{{- $leaf := printf "leaf%d" (add $i 1) }}
        info( '*** Creating Leaf ' + '{{ $leaf }}\n' )
        leaves.append(self.addSwitch(name='{{ $leaf }}', cls=StratumBmv2Switch, cpuport=CPU_PORT))
{{- end }}

{{- range $i, $junk := until (.Values.numSpines|int) -}}
{{- $spine := printf "spine%d" (add $i 1) }}
        info( '*** Creating Spine ' + '{{ $spine }}\n' )
        spines.append(self.addSwitch(name='{{ $spine }}', cls=StratumBmv2Switch, cpuport=CPU_PORT))
{{- end }}

        for spine in spines:
            for leaf in leaves:
                info( '*** Creating link ' + str(spine) + ' ' + str(leaf) + '\n')
                self.addLink(spine, leaf)
                info( '*** Created link ' + str(spine) + ' ' + str(leaf) + '\n')


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
