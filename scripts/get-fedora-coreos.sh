#!/usr/bin/env bash
# Based on https://github.com/poseidon/matchbox/blob/master/scripts/get-fedora-coreos
# USAGE: ./scripts/get-fedora-coreos
# USAGE: ./scripts/get-fedora-coreos stream version dest
#
set -eou pipefail

ARCH=${1:-"x86_64"}
STREAM=${2:-"stable"}
VERSION=${3:-"34.20211016.3.0"}
DEST_DIR=${4:-"$PWD/data/fedora-coreos"}
DEST=$DEST_DIR/fedora-coreos
BASE_URL=https://builds.coreos.fedoraproject.org/prod/streams/$STREAM/builds/$VERSION/$ARCH

# check stream/version exist based on the header response
if ! curl -s -I $BASE_URL/fedora-coreos-$VERSION-metal.$ARCH.raw.xz | grep -q -E '^HTTP/[0-9.]+ [23][0-9][0-9]' ; then
  echo "Stream or Version not found"
  exit 1
fi

if [ ! -d "$DEST" ]; then
  echo "Creating directory $DEST"
  mkdir -p $DEST
fi

echo "Downloading Fedora CoreOS $STREAM $VERSION images to $DEST"

# PXE kernel
echo "fedora-coreos-$VERSION-live-kernel-$ARCH"
curl -# $BASE_URL/fedora-coreos-$VERSION-live-kernel-$ARCH -o $DEST/fedora-coreos-$VERSION-live-kernel-$ARCH

# PXE initrd
echo "fedora-coreos-$VERSION-live-initramfs.$ARCH.img"
curl -# $BASE_URL/fedora-coreos-$VERSION-live-initramfs.$ARCH.img -o $DEST/fedora-coreos-$VERSION-live-initramfs.$ARCH.img

# rootfs
echo "fedora-coreos-$VERSION-live-rootfs.$ARCH.img"
curl -# $BASE_URL/fedora-coreos-$VERSION-live-rootfs.$ARCH.img -o $DEST/fedora-coreos-$VERSION-live-rootfs.$ARCH.img

# Install image
echo "fedora-coreos-$VERSION-metal.$ARCH.raw.xz"
curl -# $BASE_URL/fedora-coreos-$VERSION-metal.$ARCH.raw.xz -o $DEST/fedora-coreos-$VERSION-metal.$ARCH.raw.xz
echo "fedora-coreos-$VERSION-metal.$ARCH.raw.xz.sig"
curl -# $BASE_URL/fedora-coreos-$VERSION-metal.$ARCH.raw.xz.sig -o $DEST/fedora-coreos-$VERSION-metal.$ARCH.raw.xz.sig

