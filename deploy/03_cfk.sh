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
# mds-token

### Other
# CRDs <- not cleaned up
# Adds repos for helm <- todo custom repo name

# Install Ingress Nginx and Confluent Helm Repos
helm repo add confluentinc https://packages.confluent.io/helm --force-update
helm repo update

# Create namespaces if they don't exist
kubectl create namespace ${NAMESPACE} --dry-run=client -oyaml | kubectl apply -f -

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

# Copy CA certificates
copy_ca_certs

create_certificate_secret kraft
create_certificate_secret kafka
create_certificate_secret connect
create_certificate_secret controlcenter
create_certificate_secret schemaregistry
create_certificate_secret client

remove_if_deleted secret mds-token

kubectl create secret generic mds-token \
  --from-file=mdsPublicKey.pem=assets/mds/mds.pub \
  --from-file=mdsTokenKeyPair.pem=assets/mds/mds.key \
  --namespace ${NAMESPACE} \
    --save-config \
    --dry-run=client \
    -oyaml | kubectl apply -f -

wait_for_pod app=confluent-operator