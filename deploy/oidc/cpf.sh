#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

#### Helm
# FKO

# #### Manifests: manifests/cmf-rbac
#     ClusterRole/${CMF_SERVICE_ACCOUNT} \
#     ClusterRoleBinding/${CMF_SERVICE_ACCOUNT} \
#     CMFRestClass/default \
#     Role/${CMF_SERVICE_ACCOUNT} \
#     RoleBinding/${CMF_SERVICE_ACCOUNT} \
#     ServiceAccount/${CMF_SERVICE_ACCOUNT} \

# #### Secrets
#     Secret/cmf-encryption-key
#     Secret/tls-cmf-service
#     Secret/tls-cmf-full

##### Helm
# CMF

# #### Manifests: manifests/flink
#     FlinkApplication/state-machine-example
#     FlinkEnvironment/${NAMESPACE}

# FKO: disable cert-manager cause it's super flaky
helm upgrade --install cp-flink-kubernetes-operator \
    confluentinc/flink-kubernetes-operator \
    --set operatorPod.resources.requests.cpu=100m \
    --set watchNamespaces=\{"${NAMESPACE}"\} \
    --set webhook.create=false \
    --namespace ${NAMESPACE} \
    --version ${FKO_VERSION}

delete_if_deleted secret cmf-encryption-key

kubectl create secret generic cmf-encryption-key \
        --from-file=encryption-key=./assets/cmf.key \
        --namespace ${NAMESPACE} \
        --dry-run=client -oyaml --save-config \
    | kubectl apply -f -

for RESOURCE in \
    cmf-service;
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

delete_if_deleted secret tls-cmf-full

kubectl create secret generic tls-cmf-full \
    --from-file=ca.crt=${CERT_DIR}/ca.crt \
    --from-file=cmf.crt=${CERT_DIR}/cmf-service.pem \
    --from-file=cmf.key=${CERT_DIR}/cmf-service-key.pem \
    --from-file=truststore.p12=${CERT_DIR}/cmf-service-truststore.p12 \
    --from-file=keystore.p12=${CERT_DIR}/cmf-service.p12 \
        --namespace ${NAMESPACE} \
        --save-config \
        --dry-run=client \
    -oyaml | kubectl apply -f -

deploy_manifests ./manifests/cmf/oidc

envsubst < ./assets/cmf-values-oidc.yaml > ${LOCAL_DIR}/cmf-values.yaml

# CMF
helm upgrade --install cmf \
    confluentinc/confluent-manager-for-apache-flink \
    --values ${LOCAL_DIR}/cmf-values.yaml \
    --namespace ${NAMESPACE} \
    --version ${CMF_VERSION}

deploy_manifests ./manifests/flink
