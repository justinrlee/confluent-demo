#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

export MANIFEST_DIR=./manifests/keycloak

export CERT_DIR=${LOCAL_DIR}/certs
export CFSSL_DIR=${LOCAL_DIR}/cfssl
mkdir -p $CERT_DIR $CFSSL_DIR

kubectl create namespace ${KEYCLOAK_NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

## Deploy manifests
cp ./assets/ca.crt ${CERT_DIR}/ca.crt
cp ./assets/ca.key ${CERT_DIR}/ca.key
cp ./assets/cfssl-ca.json ${CFSSL_DIR}/cfssl-ca.json
cp ./assets/cfssl-cert.json ${CFSSL_DIR}/cfssl-cert.json

openssl x509 -in ${CERT_DIR}/ca.crt -text -noout

export RESOURCE=keycloak

envsubst < ./assets/cfssl-cert.json | tee ${CFSSL_DIR}/${RESOURCE}.json

cfssl gencert \
    -ca ${CERT_DIR}/ca.crt \
    -ca-key ${CERT_DIR}/ca.key \
    -config ${CFSSL_DIR}/cfssl-ca.json \
    -profile server \
    ${CFSSL_DIR}/${RESOURCE}.json | cfssljson -bare ${CERT_DIR}/${RESOURCE}

kubectl -n ${KEYCLOAK_NAMESPACE} create secret tls tls-keycloak \
        --cert=${CERT_DIR}/keycloak.pem \
        --key=${CERT_DIR}/keycloak-key.pem \
        --dry-run=client -oyaml --save-config \
    | kubectl apply -f -

# Populating keycloak realm configmap
kubectl -n ${KEYCLOAK_NAMESPACE} create configmap keycloak-realm \
        --from-file=realm.json=${MANIFEST_DIR}/realm.json \
        --dry-run=client -oyaml --save-config \
    | kubectl apply -f -

deploy_manifests ${MANIFEST_DIR}
