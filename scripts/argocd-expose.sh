#!/usr/bin/bash
# Expose argocd web interface

export DISPLAY=:0
xdg-open https://localhost:9443
vagrant ssh -c '\
    ARGO_PASS=`kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d` && \
    echo "--- ADMIN PASS ---" && \
    echo && \
    echo "${ARGO_PASS}" && \
    echo && \
    echo "--- ADMIN PASS ---" && \
    kubectl port-forward svc/argocd-server -n argocd 9443:443' \
    -- -L localhost:9443:localhost:9443
