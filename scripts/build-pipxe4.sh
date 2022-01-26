#!/bin/bash
set -xe
make -C /opt disable-ram-limit
make -C /opt enable-gzip
make -C /opt default-boot-pxe
make -C /opt

