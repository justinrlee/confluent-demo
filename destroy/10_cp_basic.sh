#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

# From manifests/basic
kubectl -n ${NAMESPACE} delete \
    KafkaTopic/shoe-customers \
    KafkaTopic/shoe-products \
    KafkaTopic/shoe-orders \
        || true

kubectl -n ${NAMESPACE} delete \
    controlcenter/controlcenter \
    ingress/controlcenter \
        || true

kubectl -n ${NAMESPACE} delete \
    connect/connect \
        || true

kubectl -n ${NAMESPACE} delete \
    schemaregistry/schemaregistry \
    ingress/schemaregistry \
        || true

kubectl -n ${NAMESPACE} delete \
    kafkarestclass/default \
        || true

kubectl -n ${NAMESPACE} delete \
    kafka/kafka \
    service/kafka-bootstrap \
    ingress/kafka \
        || true

kubectl -n ${NAMESPACE} delete \
    kraftcontroller/kraft \
        || true

# Manually created (TODO)