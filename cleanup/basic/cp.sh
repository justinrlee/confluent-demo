#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

# From manifests/basic
kubectl -n ${NAMESPACE} delete \
    KafkaTopic/shoe-customers \
    KafkaTopic/shoe-products \
    KafkaTopic/shoe-orders

kubectl -n ${NAMESPACE} delete \
    controlcenter/controlcenter \
    ingress/ingress-controlcenter

kubectl -n ${NAMESPACE} delete \
    connect/connect

kubectl -n ${NAMESPACE} delete \
    schemaregistry/schemaregistry \
    ingress/ingress-schemaregistry

kubectl -n ${NAMESPACE} delete \
    kafkarestclass/default

kubectl -n ${NAMESPACE} delete \
    kafka/kafka \
    service/kafka-bootstrap \
    ingress/ingress-kafka

kubectl -n ${NAMESPACE} delete \
    kraftcontroller/kraft

kubectl -n ${NAMESPACE} delete \
    statefulset/confluent-utility

# Manually created (TODO)