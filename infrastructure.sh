#!/bin/bash

ACTION="$1"

GO=`which go`
KUBECTL=`which kubectl`
TERRAFORM=`which terraform`
PLAN="production.plan"

echo "------------------------------------------------------------------------"
echo "Plan: ${PLAN}"
echo "------------------------------------------------------------------------"
echo "go: ${GO}"
echo "kubectl: ${KUBECTL}"
echo "terraform: ${TERRAFORM}"
echo "------------------------------------------------------------------------"

if [ ! -f "${GO}" ]; then
    echo "ERROR: go executable not found at '${GO}'"
fi

if [ ! -f "${KUBECTL}" ]; then
    echo "ERROR: kubectl executable not found at '${KUBECTL}'"
fi

if [ ! -f "${TERRAFORM}" ]; then
    echo "ERROR: terraform executable not found at '${TERRAFORM}'"
fi

if [ "$ACTION" = "plan" ] || [ "$ACTION" = "start" ]; then
    $TERRAFORM init
    $TERRAFORM plan -out $PLAN
fi

if [ "$ACTION" = "start" ]; then
    $TERRAFORM apply "$PLAN"
    
    echo "export KUBECONFIG=$KUBECONFIG:~/.kube/$PLAN" >> ~/.zshrc
    source ~/.zshrc
    
    $TERRAFORM output config-map > config-map-aws-auth.yaml
    $KUBECTL apply -f config-map-aws-auth.yaml
    $KUBECTL get nodes --watch
fi

if [ "$ACTION" = "stop" ];  then
    $TERRAFORM destroy
fi
