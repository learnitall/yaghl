#!/bin/bash
set -xe

KUBECONFIG=./data/k3s.yaml

echo "Installing cilium"
cilium install

echo "Waiting for success"
cilium status --wait

echo "Enabling hubble"
cilium enable hubble --ui

echo "Waiting for success"
cilium status --wait

echo "Running connectivity test"
cilium connectivity test
kubectl delete ns cilium-test

