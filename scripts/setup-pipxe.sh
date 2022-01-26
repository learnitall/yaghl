#!/usr/bin/env bash
# https://github.com/raspberrypi/firmware

set -eux

PIPXE4_PATH=${1:-"../data/pipxe4"}
PIPXE4_ZIP=$PIPXE4_PATH/pipxe4.zip

TFTPBOOT=${2:-"../data/tftpboot"}

if [ ! -d $PIPXE4_PATH ]; then
  echo "Cloning pipxe4..."
  git clone https://github.com/learnitall/pipxe4.git $PIPXE4_PATH
fi

if [ ! -f $PIPXE4_ZIP ]; then
    make -C $PIPXE4_PATH image
    podman run \
        --name pipxe4\
        -v ./build-pipxe4.sh:/run.sh:Z \
        pipxe4 \
        /run.sh

    make -C $PIPXE4_PATH image_copy
fi

cp $PIPXE4_ZIP $TFTPBOOT
cd $TFTPBOOT
unzip pipxe4.zip

