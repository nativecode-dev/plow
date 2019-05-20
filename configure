#!/bin/bash

#-------------------------------------------------------------------------------
# Environment Variables
#-------------------------------------------------------------------------------
export ENVIRONMENT=${1:-production}
export ENVIRONMENT_ACTION=${2:-help}

export BASH=`which bash`
export HOME=`eval "echo ~/"`
export SHELL=$(echo $SHELL)

export AWS_IAM_AUTH=`which aws-iam-authenticator`

#-------------------------------------------------------------------------------
# Show Help
#-------------------------------------------------------------------------------
if [ "${ENVIRONMENT_ACTION}" = "help" ]; then
    echo "ENVIRONMENT: ${ENVIRONMENT}"
    echo "ENVIRONMENT_ACTION: ${ENVIRONMENT_ACTION}"
    exit
fi

#-------------------------------------------------------------------------------
# Ensure Kubernetes Profile Folder
#-------------------------------------------------------------------------------
if [ ! -h "${HOME}/.kube" ]; then
    echo "Profile symlink does not exist"
    ln -s ${HOME}/snap/eksctl/current ${HOME}/.kube
fi

#-------------------------------------------------------------------------------
# Ensure aws-iam-authenticator
#-------------------------------------------------------------------------------
if [ "${AWS_IAM_AUTH}" = "" ] || [ ! -f "${AWS_IAM_AUTH}" ]; then
    mkdir -p $HOME/bin
    curl -sS -o $HOME/bin/aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.12.7/2019-03-27/bin/linux/amd64/aws-iam-authenticator > /dev/null
    chmod +x $HOME/bin/aws-iam-authenticator
fi

#-------------------------------------------------------------------------------
# Configure GitLab
#-------------------------------------------------------------------------------
$BASH ./env-gitlab.sh
