#!/bin/zsh
podman build -t yaghl-router containerfiles/router
podman build -t yaghl-dnsmasq containerfiles/dnsmasq

podman network create yaghl-internal \
    --driver macvlan \
    --opt parent=br1 \
    --subnet 10.0.0.0/24 \
    --gateway 10.0.0.1

podman network create yaghl-external \
    --driver bridge

podman pod create --name yaghl

# https://stackoverflow.com/questions/31870222/how-can-i-keep-a-container-running-on-kubernetes
# https://github.com/containers/podman/issues/8784
podman run \
    --detach \
    --network yaghl-external,yaghl-internal \
    --name router \
    --pod yaghl \
    --cap-add=NET_ADMIN,NET_RAW \
    --sysctl=net.ipv4.ip_forward=1 \
    -v ./scripts:/opt:Z \
    localhost/yaghl-router \
    /bin/sh -c "trap : TERM INT; /opt/router.sh; sleep infinity & wait"

podman run \
    --detach \
    --network yaghl-internal \
    --ip 10.0.0.60 \
    --add-host foremanlite.yaghl:10.0.0.70 \
    --pod yaghl \
    --name dnsmasq \
    --cap-add=NET_ADMIN,NET_RAW \
    -v ./dnsmasq/dnsmasq.conf:/etc/dnsmasq.conf:Z \
    -v ./data/tftpboot:/var/lib/tftpboot:Z \
    localhost/yaghl-dnsmasq

podman run \
    --detach \
    --network yaghl-internal \
    --ip 10.0.0.65 \
    --pod yaghl \
    --name redis \
    redis

podman run \
    --detach \
    --network yaghl-internal \
    --ip 10.0.0.70 \
    --pod yaghl \
    --name foremanlite \
    -v ./foremanlite/coreos_x86_64.json:/etc/foremanlite/groups/coreos_x86_64.json:Z \
    -v ./foremanlite/coreos.ipxe:/etc/foremanlite/data/ipxe/coreos.ipxe:Z \
    -v ./foremanlite/fedora-coreos.bu:/etc/foremanlite/data/butane/fedora-coreos.bu:Z \
    -v ./foremanlite/gunicorn_conf.py:/etc/foremanlite/exec/gunicorn_conf.py:Z \
    -v ./data/fedora-coreos:/etc/foremanlite/data/static:Z \
    -v ./foremanlite/cliconfig:/app/cliconfig:Z \
    localhost/foremanlite:0.1.0 \
    --config /app/cliconfig \
    start
