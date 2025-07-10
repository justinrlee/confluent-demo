#!/bin/bash

# set -e
# set -x

. ./versions.sh
. ./functions.sh

# TODO: Clean this up
kubectl -n ${NAMESPACE} delete \
    secret \
        admin-ldap-client \
        kafka-client \
        kafka-ldap-client \
        mds-token \
        rest-client \
        schemaregistry-client \
        tls-connect \
        tls-controlcenter \
        tls-kafka \
        tls-kraft \
        tls-schemaregistry

# This shouldn't be running, but sometimes it is
kubectl -n ${NAMESPACE} delete flinkdeployment state-machine-example

# gt 2: ignore header lines and CFK operator pod
while [[ $(kubectl -n ${NAMESPACE} get pods -l confluent-platform=true | wc -l ) -gt 2 ]];
do
    echo "Waiting for CFK-managed pods to terminate"
    kubectl -n ${NAMESPACE} get pods -l confluent-platform=true
    sleep 10
done

# gt 2: ignore header lines and CMF pod
while [[ $(kubectl -n ${NAMESPACE} get pods -l platform.confluent.io/origin=flink | wc -l ) -gt 2 ]];
do
    echo "Waiting for FKO-managed pods to terminate"
    kubectl -n ${NAMESPACE} get pods -l platform.confluent.io/origin=flink
    sleep 10
done


helm uninstall cmf \
    --namespace ${NAMESPACE}

sleep 10

helm uninstall cp-flink-kubernetes-operator \
    --namespace ${NAMESPACE}

sleep 10

helm uninstall confluent-for-kubernetes \
    -n ${NAMESPACE}

sleep 10

helm uninstall ingress-nginx \
    --namespace ${INGRESS_NGINX_NAMESPACE}

# sleep 10

# kubectl delete -f ./manifests/cert-manager/cert-manager.yaml

sleep 10

kubectl delete namespace ${NAMESPACE}