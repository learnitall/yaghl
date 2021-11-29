#!/bin/bash
set -x

for file in data/butane/*
do
    bn=$(basename -s .yaml $file)
    out=data/matchbox/ignition/$bn.ign
    butane $file -o $out
    chown --reference=$file $out
done

