#!/bin/bash

# set -e
# set -x

. ./versions.sh
. ./functions.sh

# From manifests
kubectl -n ${KEYCLOAK_NAMESPACE} delete \
    ingress/keycloak \
    ingress/keycloak-insecure \
    service/keycloak \
    service/keycloak-discovery \
    statefulset/keycloak \
    deployment/postgres \
    service/postgres

sleep 10

# Manually created
kubectl -n ${KEYCLOAK_NAMESPACE} delete \
    secret/tls-keycloak \
    configmap/keycloak-realm

kubectl delete namespace ${KEYCLOAK_NAMESPACE}