#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

kubectl -n ${NAMESPACE} delete \
    FlinkApplication/state-machine-example \
    FlinkEnvironment/${NAMESPACE}

helm -n ${NAMESPACE} uninstall cmf

kubectl -n ${NAMESPACE} delete \
    ClusterRole/${CMF_SERVICE_ACCOUNT} \
    ClusterRoleBinding/${CMF_SERVICE_ACCOUNT} \
    CMFRestClass/default \
    Role/${CMF_SERVICE_ACCOUNT} \
    RoleBinding/${CMF_SERVICE_ACCOUNT} \
    ServiceAccount/${CMF_SERVICE_ACCOUNT}