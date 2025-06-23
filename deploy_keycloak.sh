#!/bin/bash

. versions.sh

export CERT_DIR=./local/certs
export CFSSL_DIR=./local/cfssl
mkdir -p $CERT_DIR $CFSSL_DIR

cp ./assets/ca.crt ${CERT_DIR}/ca.crt
cp ./assets/ca.key ${CERT_DIR}/ca.key
cp ./assets/cfssl-ca.json ${CFSSL_DIR}/cfssl-ca.json
cp ./assets/cfssl-cert.json ${CFSSL_DIR}/cfssl-cert.json

openssl x509 -in ${CERT_DIR}/ca.crt -text -noout

export RESOURCE=keycloak

cfssl gencert \
    -ca ${CERT_DIR}/ca.crt \
    -ca-key ${CERT_DIR}/ca.key \
    -config ${CFSSL_DIR}/cfssl-ca.json \
    -profile server \
    ${CFSSL_DIR}/${RESOURCE}.json | cfssljson -bare ${CERT_DIR}/${RESOURCE}

kubectl -n default create secret tls tls-keycloak --cert=local/certs/keycloak.pem --key=local/certs/keycloak-key.pem --dry-run=client -oyaml --save-config | kubectl apply -f -

helm upgrade --install ingress-nginx \
    ingress-nginx/ingress-nginx \
    --namespace ${INGRESS_NGINX_NAMESPACE} \
    --set "controller.extraArgs.enable-ssl-passthrough=" \
    --version ${INGRESS_NGINX_VERSION}

kubectl apply -f cfk/keycloak/keycloak.yaml
kubectl apply -f cfk/keycloak/keycloak-ingress.yaml
