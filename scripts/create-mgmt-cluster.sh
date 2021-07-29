#!/bin/bash
# Create the management cluster within kvm
# Assumes helm, minikube, argocd cli and kvm are installed
# Note that this script is not idempotent

set -xe
minikube start --cpus=max --memory=max --driver=kvm --dns-domain='k8s.yaghl' --cni=flannel

# Add extra interface
minikube stop
virsh --connect qemu:///system attach-interface minikube bridge br1 --target eth2 --config
minikube start

# Add kubevirt
minikube addons enable kubevirt

# Install argocd
minikube kubectl create namespace argocd
minikube kubectl -- apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install airflow
minikube kubectl create namespace airflow
helm repo add apache-airflow https://airflow.apache.org
helm install airflow apache-airflow/airflow --namespace airflow --wait --timeout 10m0s
