#!/bin/bash

set -e

#------------------------------------------------------------------------------
# Arguments
#------------------------------------------------------------------------------
ACTION="$1"
ENVIRONMENT=${2:-"production"}



#------------------------------------------------------------------------------
# Variables
#------------------------------------------------------------------------------
ERROR_EXIT_CODE=0

GO=`which go`
HELM=`which helm`
KUBECTL=`which kubectl`
SNAP=`which snap`
TERRAFORM=`which terraform`

PLAN_NAME=$ENVIRONMENT
PLAN_FILE="env_${PLAN_NAME}.plan"
SHELL=`eval "echo ~/.zshrc"`



#------------------------------------------------------------------------------
# Validations
#------------------------------------------------------------------------------
if [ ! -f "${SNAP}" ]; then
    echo "CRITICAL ERROR: snap executable not found"
    exit 100
fi

if [ ! -f "${GO}" ]; then
    if [ "$ACTION" = "install" ]; then
        $SNAP install go
    else
        $ERROR_EXIT_CODE=101
    fi
fi

if [ ! -f "${HELM}" ]; then
    if [ "$ACTION" = "install" ]; then
        $SNAP install helm
    else
        $ERROR_EXIT_CODE=101
    fi
fi

if [ ! -f "${KUBECTL}" ]; then
    if [ "$ACTION" = "install" ]; then
        $SNAP install kubectl
    else
        $ERROR_EXIT_CODE=101
    fi
fi

if [ ! -f "${TERRAFORM}" ]; then
    if [ "$ACTION" = "install" ]; then
        $SNAP install terraform
    else
        $ERROR_EXIT_CODE=101
    fi
fi

if [ "$ERROR_EXIT_CODE" != 0 ]; then
    echo "CRITICAL ERROR: Missing required dependencies"
    exit $ERROR_EXIT_CODE
fi



#------------------------------------------------------------------------------
# Banner
#------------------------------------------------------------------------------
echo "------------------------------------------------------------------------"
echo " Plan Name:       ${PLAN_NAME}"
echo " Plan File:       ${PLAN_FILE}"
echo " Shell:           ${SHELL}"
echo "------------------------------------------------------------------------"
echo " snap:            ${SNAP}"
echo "------------------------------------------------------------------------"
echo " go:              ${GO}"
echo " helm:            ${HELM}"
echo " kubectl:         ${KUBECTL}"
echo " terraform:       ${TERRAFORM}"
echo "------------------------------------------------------------------------"



#------------------------------------------------------------------------------
# Plan
#------------------------------------------------------------------------------
if [ "$ACTION" = "fmt" ] || [ "$ACTION" = "plan" ] || [ "$ACTION" = "deploy" ] || [ "$ACTION" = "up" ]; then
    $TERRAFORM fmt
fi



#------------------------------------------------------------------------------
# Plan
#------------------------------------------------------------------------------
if [ "$ACTION" = "plan" ] || [ "$ACTION" = "deploy" ] || [ "$ACTION" = "up" ]; then
    $TERRAFORM init
    $TERRAFORM plan -out "${PLAN_FILE}"
fi



#------------------------------------------------------------------------------
# Deploy
#------------------------------------------------------------------------------
if [ "$ACTION" = "deploy" ] || [ "$ACTION" = "up" ]; then
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
if [ "$ACTION" = "destroy" ] || [ "$ACTION" = "down" ];  then
    if [ $(grep "KUBECONFIG" $SHELL | wc -l) != 0 ]; then
        sed -i '/export KUBECONFIG*/d' $SHELL
    fi
    
    if [ -f PLAN_FILE ]; then
        rm "${PLAN_FILE}"
    fi
    
    $TERRAFORM destroy
fi
