#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

###### Creates / Installs the following:

### Namespaces:
# demo namespace
# keycloak namespace
# ingress nginx namespace

### Helm Charts:
# ingress-nginx
# CFK

### Secrets:
# tls-kraft
# tls-kafka
# tls-connect
# tls-controlcenter
# tls-schemaregistry
# tls-client
# tls-client-full
# mds-token

### Other
# CRDs <- not cleaned up
# Adds repos for helm <- todo custom repo name

# Install Ingress Nginx and Confluent Helm Repos
helm repo add confluentinc https://packages.confluent.io/helm --force-update
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx --force-update
helm repo update

# Create namespaces if they don't exist
kubectl create namespace ${NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -
kubectl create namespace ${KEYCLOAK_NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -
kubectl create namespace ${INGRESS_NGINX_NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

##### Helm deploys
# Ingress NGINX
helm upgrade --install ingress-nginx \
    ingress-nginx/ingress-nginx \
    --namespace ${INGRESS_NGINX_NAMESPACE} \
    --set "controller.extraArgs.enable-ssl-passthrough=" \
    --version ${INGRESS_NGINX_VERSION}

# Upgrade CFK CRDs
helm show crds confluentinc/confluent-for-kubernetes | kubectl apply --server-side=true -f -

# CFK
helm upgrade --install confluent-for-kubernetes \
    confluentinc/confluent-for-kubernetes \
    --namespace ${OPERATOR_NAMESPACE} \
    --set namespaced=true \
    --set enableCMFDay2Ops=true \
    --set namespaceList=\{"${NAMESPACE}","${OPERATOR_NAMESPACE}"\} \
    --version ${CFK_CHART_VERSION}

# Create certificates
# export CERT_DIR=./local/certs
# export CFSSL_DIR=./local/cfssl
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
    schemaregistry \
    client \
    ;
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

    delete_if_deleted secret tls-${RESOURCE}

    kubectl create secret generic tls-${RESOURCE} \
        --from-file=cacerts.pem=${CERT_DIR}/ca.crt \
        --from-file=fullchain.pem=${CERT_DIR}/${RESOURCE}.pem \
        --from-file=privkey.pem=${CERT_DIR}/${RESOURCE}-key.pem \
        --namespace ${NAMESPACE} \
        --save-config \
        --dry-run=client \
        -oyaml | kubectl apply -f -
done

delete_if_deleted secret tls-client-full

kubectl create secret generic tls-client-full \
    --from-file=ca.crt=${CERT_DIR}/ca.crt \
    --from-file=client.crt=${CERT_DIR}/client.pem \
    --from-file=client.key=${CERT_DIR}/client-key.pem \
    --from-file=truststore.p12=${CERT_DIR}/client-truststore.p12 \
    --from-file=keystore.p12=${CERT_DIR}/client.p12 \
        --namespace ${NAMESPACE} \
        --save-config \
        --dry-run=client \
    -oyaml | kubectl apply -f -

delete_if_deleted secret mds-token

kubectl create secret generic mds-token \
  --from-file=mdsPublicKey.pem=assets/mds.pub \
  --from-file=mdsTokenKeyPair.pem=assets/mds.key \
  --namespace ${NAMESPACE} \
    --save-config \
    --dry-run=client \
    -oyaml | kubectl apply -f -

set +x
wait_for_pod app.kubernetes.io/name=ingress-nginx 1 ${INGRESS_NGINX_NAMESPACE}
# wait_for_nginx
wait_for_pod app=confluent-operator
# wait_for_cfk
set -x