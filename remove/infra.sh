#!/bin/bash

# set -e
# set -x

. ./.env
. ./functions.sh

# Basic infra
kubectl -n ${NAMESPACE} delete \
    secret \
        tls-kraft \
        tls-kafka \
        tls-connect \
        tls-controlcenter \
        tls-schemaregistry \
        tls-client \
        tls-client-full \
        || true

# OIDC infra
kubectl -n ${NAMESPACE} delete \
    secret \
        kafka-client \
        mds-token \
        rest-client \
        schemaregistry-client \
        || true

# gt 2: ignore header lines and CFK operator pod
while [[ $(kubectl -n ${NAMESPACE} get pods -l confluent-platform=true | wc -l ) -gt 2 ]];
do
    echo "Waiting 10s for CFK-managed pods to terminate"
    kubectl -n ${NAMESPACE} get pods -l confluent-platform=true
    sleep 10
done

# gt 2: ignore header lines and CMF pod
while [[ $(kubectl -n ${NAMESPACE} get pods -l platform.confluent.io/origin=flink | wc -l ) -gt 2 ]];
do
    echo "Waiting 10s for FKO-managed pods to terminate"
    kubectl -n ${NAMESPACE} get pods -l platform.confluent.io/origin=flink
    sleep 10
done

helm uninstall confluent-for-kubernetes \
    -n ${NAMESPACE}

sleep 2

helm uninstall ingress-nginx \
    --namespace ${INGRESS_NGINX_NAMESPACE}

sleep 2

kubectl delete namespace ${NAMESPACE} \
        || true