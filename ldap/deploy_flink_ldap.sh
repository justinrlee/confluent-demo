#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

export MANIFEST_DIR=./manifests/flink

# wait_for_cert_manager

# FKO: disable cert-manager cause it's super flaky
helm upgrade --install cp-flink-kubernetes-operator \
    confluentinc/flink-kubernetes-operator \
    --set webhook.create=false \
    --set operatorPod.resources.requests.cpu=100m \
    --set watchNamespaces=\{"${NAMESPACE}"\} \
    --namespace ${NAMESPACE} \
    --version ${FKO_VERSION}

kubectl create secret generic cmf-encryption-key \
        --from-file=encryption-key=./assets/cmf.key \
        --namespace ${NAMESPACE} \
        --dry-run=client -oyaml --save-config \
    | kubectl apply -f -

deploy_manifests ./manifests/cmf-rbac

# CMF
helm upgrade --install cmf \
    confluentinc/confluent-manager-for-apache-flink \
    --set resources.requests.cpu=100m \
    --set encryption.key.kubernetesSecretName=cmf-encryption-key \
    --set encryption.key.kubernetesSecretProperty=encryption-key \
    --set rbac=false \
    --set serviceAccount.create=false \
    --set serviceAccount.name=${CMF_SERVICE_ACCOUNT} \
    --namespace ${NAMESPACE} \
    --version ${CMF_VERSION}

deploy_manifests ${MANIFEST_DIR}