#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

export MANIFEST_DIR=./manifests/simple

kubectl -n ${NAMESPACE} create secret generic kafka-ldap-client \
        --from-file=plain-interbroker.txt=./assets/kafka-plain.txt \
        --from-file=plain.txt=./assets/kafka-plain.txt \
        --from-file=bearer.txt=./assets/kafka-plain.txt \
    --dry-run=client -oyaml --save-config > ${LOCAL_DIR}/secret-kafka-ldap-client.yaml
kubectl apply -f ${LOCAL_DIR}/secret-kafka-ldap-client.yaml

kubectl -n ${NAMESPACE} create secret generic admin-ldap-client \
        --from-file=ldap-server-simple.txt=./assets/ldap-admin-plain.txt \
        --from-file=ldap.txt=./assets/ldap-admin-plain.txt \
    --dry-run=client -oyaml --save-config > ${LOCAL_DIR}/secret-admin-ldap-client.yaml
kubectl apply -f ${LOCAL_DIR}/secret-admin-ldap-client.yaml

kubectl -n ${NAMESPACE} create secret generic kafka-client \
        --from-file=plain.txt=./assets/kafka-plain.txt \
        --from-file=bearer.txt=./assets/kafka-plain.txt \
    --dry-run=client -oyaml --save-config > ${LOCAL_DIR}/secret-kafka-client.yaml
kubectl apply -f ${LOCAL_DIR}/secret-kafka-client.yaml

# TODO change to sr creds
kubectl -n ${NAMESPACE} create secret generic schemaregistry-client \
        --from-file=plain.txt=./assets/kafka-plain.txt \
        --from-file=bearer.txt=./assets/kafka-plain.txt \
    --dry-run=client -oyaml --save-config > ${LOCAL_DIR}/secret-schemaregistry-client.yaml
kubectl apply -f ${LOCAL_DIR}/secret-schemaregistry-client.yaml

kubectl -n ${NAMESPACE} create secret generic rest-client \
        --from-file=bearer.txt=./assets/kafka-plain.txt \
        --from-file=basic.txt=./assets/kafka-plain.txt \
    --dry-run=client -oyaml --save-config > ${LOCAL_DIR}/secret-rest-client.yaml
kubectl apply -f ${LOCAL_DIR}/secret-rest-client.yaml

deploy_manifests ${MANIFEST_DIR}