#!/bin/bash

export REGION=us-east-1
export CLUSTER_NAME="${ENVIRONMENT}-gitlab"
export CLUSTER_VERSION=1.12
export MACHINE_TYPE=t2.medium
export NUM_NODES=2
export SERVICE_ACCOUNT=tiller

cd gitlab

if [ "$ENVIRONMENT_ACTION" = "up" ]; then
    read -p "Deploy EKS Cluster: [Y/N]: " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

$BASH ./scripts/eks_bootstrap_script ${ENVIRONMENT_ACTION}

if [ "$ENVIRONMENT_ACTION" = "up" ]; then
    read -p "Deploy GitLab: [Y/N]: " -n 1 -r
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi

    $HELM repo add gitlab https://charts.gitlab.io/
    $HELM repo update
    $HELM upgrade --install gitlab gitlab/gitlab
        \ --set certmanager-issuer.email=admin@${ENVIRONMENT_DOMAIN}
        \ --set global.hosts.domain=${ENVIRONMENT_URL}
        \ --set global.hosts.externalIP=${ENVIRONMENT_CLUSTER_IP}
        \ --set global.hosts.ssh=${ENVIRONMENT_URL}
        \ --set global.registry.bucket=${ENVIRONMENT_BUCKET}
        \ --timeout 600
fi
