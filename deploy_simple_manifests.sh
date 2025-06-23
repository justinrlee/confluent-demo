#!/bin/bash

set -e
set -x

. versions.sh

export MANIFEST_DIR=./cfk/simple
export LOCAL_DIR=./local

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

ls -1 ${MANIFEST_DIR}

for f in \
    $(ls -1 ${MANIFEST_DIR})
do
    echo ${f}
    envsubst < cfk/simple/${f} > ${LOCAL_DIR}/${f}
    kubectl apply -f ${LOCAL_DIR}/${f}
done

while [[ $(kubectl -n ${NAMESPACE} get pods -l app=controlcenter | grep '3/3' | wc -l) -lt 1 ]];
do
    echo "Waiting for ControlCenter pod to be ready"
    kubectl -n ${NAMESPACE} get pods
    echo ''
    sleep 5
done