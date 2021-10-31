#!/bin/zsh
podman network create yaghl-internal \
    --driver macvlan \
    --opt parent=br1 \
    --subnet 10.0.0.0/24

podman network create yaghl-external \
    --driver bridge

podman pod create --name yaghl

# https://stackoverflow.com/questions/31870222/how-can-i-keep-a-container-running-on-kubernetes
podman run \
    --detach \
    --network yaghl-external,yaghl-internal \
    --name router \
    --pod yaghl \
    registry.fedoraproject.org/fedora:latest \
    /bin/sh -c "trap : TERM INT; sleep infinity & wait"

podman run \
    --detach \
    --network yaghl-internal \
    --pod yaghl \
    --name dnsmasq \
    --cap-add=NET_ADMIN \
    quay.io/poseidon/dnsmasq

