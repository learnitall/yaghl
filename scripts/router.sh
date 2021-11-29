#!/bin/bash

set -x

# dnf install -y iptables iproute

ip addr add 10.0.0.1/24 dev eth1
# Need to make sure our only default route is
# through the podman bridge network.
# Otherwise, we can't reach anything outside of
# the subnet.
ip route del default via 10.0.0.1 dev eth1

# https://www.revsys.com/writings/quicktips/nat.html
iptables -t nat -A POSTROUTING -d 0.0.0.0/0 -j MASQUERADE
iptables -A FORWARD -s 0.0.0.0/0  -o eth1 -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -i eth1 -d 0.0.0.0/0 -j ACCEPT

