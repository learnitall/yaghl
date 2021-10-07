#!/bin/bash
# Create the management cluster
# Note that this script is not idempotent

set -xe

minikube start --driver=none --dns-domain='k8s.yaghl'

# Install flannel cni
kubectl apply -f https://raw.githubusercontent.com/flannel-io/flannel/v0.14.0/Documentation/kube-flannel.yml

# Install argocd
kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
sleep 5  # give it a second to get going
for dep_name in argocd-dex-server argocd-redis argocd-repo-server argocd-server
do
    kubectl rollout status deployment $dep_name -n argocd
done

# Install airflow
kubectl create namespace airflow
helm repo add apache-airflow https://airflow.apache.org
helm install airflow apache-airflow/airflow --namespace airflow
for dep_name in airflow-flower airflow-scheduler airflow-statsd airflow-webserver
do
    kubectl rollout status deployment $dep_name -n airflow
done

# Add kubevirt
minikube addons enable kubevirt
for dep_name in api controller operator
do
    kubectl rollout status deployment virt-$dep_name -n kubevirt
done

# Install virtctl
kubectl krew install virt
