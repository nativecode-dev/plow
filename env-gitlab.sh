#!/bin/bash

export REGION=us-east-1
export CLUSTER_NAME="${ENVIRONMENT}-gitlab"
export CLUSTER_VERSION=1.12
export MACHINE_TYPE=t2.small
export NUM_NODES=2
export SERVICE_ACCOUNT=tiller

cd gitlab
bash ./scripts/eks_bootstrap_script ${ENVIRONMENT_ACTION}
