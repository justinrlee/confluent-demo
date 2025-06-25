#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

# Install Ingress Nginx and Confluent Helm Repos
helm repo add confluentinc https://packages.confluent.io/helm --force-update
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx --force-update
helm repo update

# Create namespaces if they don't exist
kubectl create namespace ${NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -
kubectl create namespace ${KEYCLOAK_NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -
kubectl create namespace ${INGRESS_NGINX_NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

# Deploy cert-manager
deploy_manifests ./manifests/cert-manager

wait_for_cert_manager

##### Helm deploys
# Ingress NGINX
helm upgrade --install ingress-nginx \
    ingress-nginx/ingress-nginx \
    --namespace ${INGRESS_NGINX_NAMESPACE} \
    --set "controller.extraArgs.enable-ssl-passthrough=" \
    --version ${INGRESS_NGINX_VERSION}

# CFK
helm upgrade --install confluent-for-kubernetes \
    confluentinc/confluent-for-kubernetes \
    --namespace ${OPERATOR_NAMESPACE} \
    --set namespaced=false \
    --set enableCMFDay2Ops=true \
    --version ${CFK_CHART_VERSION}

# FKO
## Depends on cert-manager
helm upgrade --install cp-flink-kubernetes-operator \
    confluentinc/flink-kubernetes-operator \
    --set operatorPod.resources.requests.cpu=100m \
    --namespace ${NAMESPACE} \
    --version ${FKO_VERSION}

kubectl create secret generic cmf-encryption-key \
        --from-file=encryption-key=./assets/cmf.key \
        --namespace ${NAMESPACE} \
        --dry-run=client -oyaml --save-config \
    | kubectl apply -f -

# CMF
helm upgrade --install cmf \
    confluentinc/confluent-manager-for-apache-flink \
    --set resources.requests.cpu=100m \
    --set encryption.key.kubernetesSecretName=cmf-encryption-key \
    --set encryption.key.kubernetesSecretProperty=encryption-key \
    --namespace ${NAMESPACE} \
    --version ${CMF_VERSION}

# Create certificates
export CERT_DIR=./local/certs
export CFSSL_DIR=./local/cfssl
mkdir -p ${CERT_DIR} ${CFSSL_DIR}

env | sort

# Copy CA certificates
cp ./assets/ca.crt ${CERT_DIR}/ca.crt
cp ./assets/ca.key ${CERT_DIR}/ca.key
cp ./assets/cfssl-ca.json ${CFSSL_DIR}/cfssl-ca.json
cp ./assets/cfssl-cert.json ${CFSSL_DIR}/cfssl-cert.json

openssl x509 -in ${CERT_DIR}/ca.crt -text -noout

for RESOURCE in \
    kraft \
    kafka \
    connect \
    controlcenter \
    schemaregistry;
do
    export RESOURCE
    envsubst < ./assets/cfssl-cert.json | tee ${CFSSL_DIR}/${RESOURCE}.json

    echo ''

    rm -f ${CERT_DIR}/${RESOURCE}*

    cfssl gencert \
        -ca ${CERT_DIR}/ca.crt \
        -ca-key ${CERT_DIR}/ca.key \
        -config ${CFSSL_DIR}/cfssl-ca.json \
        -profile server \
        ${CFSSL_DIR}/${RESOURCE}.json | cfssljson -bare ${CERT_DIR}/${RESOURCE}

    openssl pkcs12 -export \
        -in ${CERT_DIR}/${RESOURCE}.pem \
        -inkey ${CERT_DIR}/${RESOURCE}-key.pem \
        -out ${CERT_DIR}/${RESOURCE}.p12 \
        -name ${RESOURCE} \
        -CAfile ${CERT_DIR}/ca.crt \
        -caname CARoot \
        -passin pass:confluent \
        -password pass:confluent

    keytool -importcert \
        -keystore ${CERT_DIR}/${RESOURCE}.p12 \
        -alias CAroot \
        -file ${CERT_DIR}/ca.crt \
        -storepass confluent \
        -noprompt
    
    keytool -importcert \
        -keystore ${CERT_DIR}/${RESOURCE}-truststore.p12 \
        -alias CAroot \
        -file ${CERT_DIR}/ca.crt \
        -storepass confluent \
        -noprompt

    kubectl create secret generic tls-${RESOURCE} \
        --from-file=cacerts.pem=${CERT_DIR}/ca.crt \
        --from-file=fullchain.pem=${CERT_DIR}/${RESOURCE}.pem \
        --from-file=privkey.pem=${CERT_DIR}/${RESOURCE}-key.pem \
        --namespace ${NAMESPACE} \
        --save-config \
        --dry-run=client \
        -oyaml | kubectl apply -f -
done

kubectl create secret generic mds-token \
  --from-file=mdsPublicKey.pem=assets/mds.pub \
  --from-file=mdsTokenKeyPair.pem=assets/mds.key \
  --namespace ${NAMESPACE} \
    --save-config \
    --dry-run=client \
    -oyaml | kubectl apply -f -

wait_for_cfk