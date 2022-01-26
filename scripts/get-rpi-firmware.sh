#!/usr/bin/env bash
# https://github.com/raspberrypi/firmware

set -eux

DEST=${1:-"../data/tftpboot"}

if [ ! -d $DEST ]; then
  echo "Creating directory $DEST"
  mkdir -p $DEST
fi

curl --output-dir $DEST -OL https://github.com/raspberrypi/firmware/raw/master/boot/start4.elf
curl --output-dir $DEST -OL https://github.com/raspberrypi/firmware/raw/master/boot/fixup4.dat
curl --output-dir $DEST -OL https://github.com/raspberrypi/firmware/raw/master/boot/bcm2711-rpi-4-b.dtb
curl --output-dir $DEST -OL https://github.com/raspberrypi/firmware/raw/master/boot/kernel.img

