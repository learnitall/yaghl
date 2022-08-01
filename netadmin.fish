#!/bin/fish
podman build -t yaghl-router containerfiles/router
podman build -t yaghl-dnsmasq containerfiles/dnsmasq

podman network create yaghl-internal \
    --driver macvlan \
    --opt parent=enp4s0 \
    --subnet 192.168.3.0/24 \
    --gateway 192.168.3.1

# https://blog.oddbit.com/post/2018-03-12-using-docker-macvlan-networks/
if not nmcli con show yaghl-shim
    ip link add yaghl-shim link enp4s0 type macvlan mode bridge
    ip addr add 192.168.3.55/32 dev yaghl-shim
    ip link set yaghl-shim up
    ip route add 192.168.3.0/24 dev yaghl-shim
end

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
    -v ./scripts/router.sh:/opt/router.sh:Z \
    localhost/yaghl-router \
    /bin/sh -c "trap : TERM INT; /opt/router.sh; sleep infinity & wait"

podman run \
    --detach \
    --network yaghl-internal \
    --ip 192.168.3.60 \
    --add-host foremanlite.yaghl:192.168.3.70 \
    --add-host rpi1.yaghl:192.168.3.121 \
    --add-host rpi2.yaghl:192.168.3.122 \
    --add-host rpi3.yaghl:192.168.3.123 \
    --add-host nuc1.yaghl:192.168.3.124 \
    --add-host nuc2.yaghl:192.168.3.125 \
    --pod yaghl \
    --name dnsmasq \
    --cap-add=NET_ADMIN,NET_RAW \
    -v ./dnsmasq/dnsmasq.conf:/etc/dnsmasq.conf:Z \
    -v ./data/tftpboot:/var/lib/tftpboot:Z \
    localhost/yaghl-dnsmasq

podman run \
    --detach \
    --network yaghl-internal \
    --ip 192.168.3.65 \
    --pod yaghl \
    --name redis \
    -v ./data/redis:/data:Z \
    redis \
    redis-server \
    --save 60 1 \

podman run \
    --detach \
    --network yaghl-internal \
    --ip 192.168.3.70 \
    --pod yaghl \
    --name foremanlite \
    # Config
    -v ./foremanlite/config/gunicorn_conf.py:/etc/foremanlite/exec/gunicorn_conf.py:Z \
    -v ./foremanlite/config/cliconfig:/app/cliconfig:Z \
    # Groups
    -v ./foremanlite/groups:/etc/foremanlite/groups:Z \
    # ipxe
    -v ./foremanlite/ipxe/coreos.ipxe:/etc/foremanlite/data/ipxe/coreos.ipxe:Z \
    # Static data
    -v ./data/fedora-coreos:/etc/foremanlite/data/static:Z \
    # Templates
    -v ./foremanlite/templates:/etc/foremanlite/data/templates:Z \
    # Butane
    -v ./foremanlite/butane:/etc/foremanlite/data/butane:Z \
    localhost/foremanlite:0.1.0 \
    --config /app/cliconfig \
    start
