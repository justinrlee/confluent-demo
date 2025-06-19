#!/bin/bash

# set -e
# set -x

. ./versions.sh

# Could do all of these as a single command
kubectl -n ${NAMESPACE} delete \
    controlcenter/controlcenter

kubectl -n ${NAMESPACE} delete \
    connect/connect

kubectl -n ${NAMESPACE} delete \
    schemaregistry/schemaregistry

kubectl -n ${NAMESPACE} delete \
    kafkarestclass/default

kubectl -n ${NAMESPACE} delete \
    kafka/kafka service/kafka-bootstrap

kubectl -n ${NAMESPACE} delete \
    kraftcontroller/kraft

kubectl -n ${NAMESPACE} delete \
    statefulset/confluent-utility
    
kubectl -n ${NAMESPACE} delete \
    statefulset/ldap service/ldap

kubectl -n ${NAMESPACE} delete \
    ingress \
        ingress-schemaregistry \
        ingress-kafka \
        ingress-controlcenter

kubectl -n ${NAMESPACE} delete \
    flinkapplication/state-machine-example

kubectl -n ${NAMESPACE} delete \
    flinkenvironment/${NAMESPACE}

kubectl -n ${NAMESPACE} delete \
    cmfrestclass/default

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
    kubectl -n ${NAMESPACE} get pods -l confluent-platform=true
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

sleep 10

kubectl delete -f https://github.com/jetstack/cert-manager/releases/download/v1.8.2/cert-manager.yaml

sleep 10

kubectl delete namespace ${NAMESPACE}

# TODO: Uninstall nginx
