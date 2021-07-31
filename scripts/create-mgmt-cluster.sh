#!/bin/bash
# Create the management cluster
# Assumes helm, minikube, podman, kvm and krew are installed
# Note that this script is not idempotent

set -xe

minikube start --driver=docker --dns-domain='k8s.yaghl' --cni=flannel

# Add kubevirt
minikube addons enable kubevirt

# Install virtctl
kubectl krew install virt

# Install argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

# Install airflow
kubectl create namespace airflow
helm repo add apache-airflow https://airflow.apache.org
helm install airflow apache-airflow/airflow --namespace airflow --wait --timeout 10m0s
