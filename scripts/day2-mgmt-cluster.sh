#!/bin/bash
# Day 2 Management Cluster Operations

# Setup argo apps
ARGO_PASS=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d`
kubectl port-forward svc/argocd-server -n argocd 8443:443 &

sleep 1
set +x

argocd login localhost:8443 \
    --name day2 \
    --username admin \
    --password "${ARGO_PASS}" \
    --insecure \
    --port-forward-namespace argocd
argocd app create kubevirt-cdi \
    --repo https://github.com/learnitall/yaghl.git \
    --path kubevirt-cdi \
    --dest-server https://kubernetes.default.svc \
    --port-forward-namespace argocd \
    --sync-policy auto \
    --sync-option Prune=true
argocd app create cni \
    --repo https://github.com/learnitall/yaghl.git \
    --path cni \
    --dest-server https://kubernetes.default.svc \
    --port-forward-namespace argocd \
    --sync-policy auto \
    --sync-option Prune=true
argocd app create vyos \
    --repo https://github.com/learnitall/yaghl.git \
    --path vyos \
    --dest-server https://kubernetes.default.svc \
    --port-forward-namespace argocd \
    --sync-policy auto \
    --sync-option Prune=true

argocd logout day2
ps aux | grep -e 'kubectl port-forward svc/argocd-server -n argocd 8443:443$' | awk '{print $2}' | xargs kill
