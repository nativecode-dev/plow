#!/bin/bash

export ENVIRONMENT=${1:-production}
export ENVIRONMENT_ACTION=${2:-help}

if [ "${ENVIRONMENT_ACTION}" = "help" ]; then
    echo "ENVIRONMENT: ${ENVIRONMENT}"
    echo "ENVIRONMENT_ACTION: ${ENVIRONMENT_ACTION}"
    exit
fi

bash ./env-gitlab.sh
