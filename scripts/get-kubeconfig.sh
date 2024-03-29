#!/bin/bash
set -xe

KUBECONFIG=./data/k3s.yaml

echo "Getting kubeconfig"

rsync -avz --rsync-path="sudo rsync" -e "ssh -i ./data/sshkeys/id_rsa" core@192.168.3.124:/etc/rancher/k3s/k3s.yaml $KUBECONFIG
sed -i 's/127.0.0.1/192.168.3.124/g' $KUBECONFIG

