#!/bin/bash

# set -e
# set -x

. ./versions.sh

kubectl -n ${KEYCLOAK_NAMESPACE} delete \
    ingress/keycloak \
    ingress/keycloak-insecure \
    service/keycloak \
    service/keycloak-discovery \
    statefulset/keycloak \
    deployment/postgres \
    service/postgres

sleep 10

kubectl delete namespace ${KEYCLOAK_NAMESPACE}