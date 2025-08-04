#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

###### Creates / Installs the following:

### Helm charts
# * FKO
# * cmf

### Secrets
# cmf-encryption-key
# tls-cmf-full

### Manifests (manifests/cmf-basic and manifests/flink)
### manifests/cmf/basic
    # ClusterRole/${CMF_SERVICE_ACCOUNT} \
    # ClusterRoleBinding/${CMF_SERVICE_ACCOUNT} \
    # CMFRestClass/default \
    # Role/${CMF_SERVICE_ACCOUNT} \
    # RoleBinding/${CMF_SERVICE_ACCOUNT} \
    # ServiceAccount/${CMF_SERVICE_ACCOUNT}
### manifests/flink
    # FlinkApplication/state-machine-example \
    # FlinkEnvironment/${NAMESPACE} \

# FKO: disable cert-manager cause it's super flaky
helm upgrade --install cp-flink-kubernetes-operator \
    confluentinc/flink-kubernetes-operator \
    --set operatorPod.resources.requests.cpu=100m \
    --set watchNamespaces=\{"${NAMESPACE}"\} \
    --set webhook.create=false \
    --namespace ${NAMESPACE} \
    --version ${FKO_VERSION}

# TODO: Update CRDs?

remove_if_deleted secret cmf-encryption-key

kubectl create secret generic cmf-encryption-key \
        --from-file=encryption-key=./assets/cmf/cmf.key \
        --namespace ${NAMESPACE} \
        --dry-run=client -oyaml --save-config \
    | kubectl apply -f -

copy_ca_certs
create_certificate_secret cmf

deploy_manifests ./assets/manifests/cmf/basic

envsubst < ./assets/cmf/values-basic.yaml > ${LOCAL_DIR}/cmf-values.yaml

# CMF
helm upgrade --install cmf \
    confluentinc/confluent-manager-for-apache-flink \
    --values ${LOCAL_DIR}/cmf-values.yaml \
    --namespace ${NAMESPACE} \
    --version ${CMF_VERSION}

deploy_manifests ./assets/manifests/flink
