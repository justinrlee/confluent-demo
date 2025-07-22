#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

# Todo - remove all compute statements, catalog, pools

kubectl -n ${NAMESPACE} delete \
    FlinkApplication/state-machine-example \
    FlinkEnvironment/${NAMESPACE}

# Todo - check for removal of all FA/FE
sleep 5

helm -n ${NAMESPACE} uninstall cmf

# Todo - check for removal of all FD
sleep 5

kubectl -n ${NAMESPACE} delete \
    ClusterRole/${CMF_SERVICE_ACCOUNT} \
    ClusterRoleBinding/${CMF_SERVICE_ACCOUNT} \
    CMFRestClass/default \
    Role/${CMF_SERVICE_ACCOUNT} \
    RoleBinding/${CMF_SERVICE_ACCOUNT} \
    ServiceAccount/${CMF_SERVICE_ACCOUNT}

kubectl -n ${NAMESPACE} delete \
    Secret/tls-cmf-full \
    Secret/tls-cmf-service \
    Secret/cmf-encryption-key

helm -n ${NAMESPACE} uninstall cp-flink-kubernetes-operator