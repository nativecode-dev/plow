#!/bin/bash

set -e

#------------------------------------------------------------------------------
# Arguments
#------------------------------------------------------------------------------
ACTION="$1"

#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------
GO=`which go`
KUBECTL=`which kubectl`
TERRAFORM=`which terraform`

PLAN_NAME="production"
PLAN_FILE="${PLAN_NAME}.plan"
SHELL=`eval "echo ~/.zshrc"`

echo "------------------------------------------------------------------------"
echo " Plan:         ${PLAN_NAME}"
echo " Plan File:    ${PLAN_FILE}"
echo " Shell:        ${SHELL}"
echo "------------------------------------------------------------------------"
echo " go:           ${GO}"
echo " kubectl:      ${KUBECTL}"
echo " terraform:    ${TERRAFORM}"
echo "------------------------------------------------------------------------"

#------------------------------------------------------------------------------
# Validations
#------------------------------------------------------------------------------
if [ ! -f "${GO}" ]; then
    echo "ERROR: go executable not found at '${GO}'"
fi

if [ ! -f "${KUBECTL}" ]; then
    echo "ERROR: kubectl executable not found at '${KUBECTL}'"
fi

if [ ! -f "${TERRAFORM}" ]; then
    echo "ERROR: terraform executable not found at '${TERRAFORM}'"
fi

#------------------------------------------------------------------------------
# Plan
#------------------------------------------------------------------------------
if [ "$ACTION" = "plan" ] || [ "$ACTION" = "deploy" ]; then
    $TERRAFORM init
    $TERRAFORM fmt
    $TERRAFORM plan -out "${PLAN_FILE}"
fi

#------------------------------------------------------------------------------
# Deploy
#------------------------------------------------------------------------------
if [ "$ACTION" = "deploy" ]; then
    $TERRAFORM apply "${PLAN_FILE}"
    
    if [ $(grep "KUBECONFIG" $SHELL | wc -l) = 0 ]; then
        echo "export KUBECONFIG=$KUBECONFIG:~/.kube/${PLAN_NAME}" >> $SHELL
        source ~/.zshrc
    fi
    
    $TERRAFORM output config-map > config-map-aws-auth.yaml
    $KUBECTL apply -f config-map-aws-auth.yaml
    $KUBECTL get nodes --watch
fi

#------------------------------------------------------------------------------
# Destroy
#------------------------------------------------------------------------------
if [ "$ACTION" = "destroy" ];  then
    $TERRAFORM destroy
    rm "${PLAN_FILE}"
fi
