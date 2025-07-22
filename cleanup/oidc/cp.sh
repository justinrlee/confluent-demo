#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

# From manifests
# Could do all of these as a single command
kubectl -n ${NAMESPACE} delete \
    confluentrolebinding/manual-admin \
    confluentrolebinding/manual-admin-connect \
    confluentrolebinding/manual-admin-sr

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

kubectl -n ${NAMESPACE} delete \
    flinkapplication/state-machine-example

kubectl -n ${NAMESPACE} delete \
    flinkenvironment/${NAMESPACE}

kubectl -n ${NAMESPACE} delete \
    cmfrestclass/default

# Manually created (TODO)