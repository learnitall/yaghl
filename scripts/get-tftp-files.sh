#!/usr/bin/env bash
# Run from scripts directory
# Sourced from https://raw.githubusercontent.com/poseidon/dnsmasq/master/get-tftp-files
set -eu

DEST=${1:-"../data/tftpboot"}

if [ ! -d $DEST ]; then
  echo "Creating directory $DEST"
  mkdir -p $DEST
fi

curl -s -o $DEST/undionly.kpxe http://boot.ipxe.org/undionly.kpxe
cp $DEST/undionly.kpxe $DEST/undionly.kpxe.0
curl -s -o $DEST/ipxe.efi http://boot.ipxe.org/ipxe.efi
