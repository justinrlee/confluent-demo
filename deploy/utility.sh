#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

kubectl create configmap utility-config \
    --from-file ./assets/config/basic \
    -n ${NAMESPACE} \
    --save-config \
    --dry-run=client \
    -oyaml > ${LOCAL_DIR}/utility-config.yaml

kubectl -n ${NAMESPACE} apply -f ${LOCAL_DIR}/utility-config.yaml

export MANIFEST_DIR=./assets/manifests/utility

deploy_manifests ${MANIFEST_DIR}