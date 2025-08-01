#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

# Todo - remove all compute statements, catalog, pools

kubectl -n ${NAMESPACE} delete \
    FlinkApplication/state-machine-example \
    FlinkEnvironment/${NAMESPACE} \
        || true

# Todo - check for removal of all FA/FE
clean_up_flinkdeployment
sleep 2

helm -n ${NAMESPACE} uninstall cmf

# Todo - check for removal of all FD
sleep 2

kubectl -n ${NAMESPACE} delete \
    ClusterRole/${CMF_SERVICE_ACCOUNT} \
    ClusterRoleBinding/${CMF_SERVICE_ACCOUNT} \
    CMFRestClass/default \
    Role/${CMF_SERVICE_ACCOUNT} \
    RoleBinding/${CMF_SERVICE_ACCOUNT} \
    ServiceAccount/${CMF_SERVICE_ACCOUNT} \
        || true

kubectl -n ${NAMESPACE} delete \
    Secret/tls-cmf-full \
    Secret/tls-cmf-service \
    Secret/cmf-encryption-key \
        || true

helm -n ${NAMESPACE} uninstall cp-flink-kubernetes-operator