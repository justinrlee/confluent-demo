#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

###### manifests/basic includes these objects:
# StatefulSet/confluent-utility

# KRaftController/kraft

# Kafka/kafka
# Ingress/ingress-kafka
# Service/kafka-bootstrap
# KafkaRestClass/default

# SchemaRegistry/schemaregistry
# Ingress/ingress-schemaregistry

# Connect/connect

# ControlCenter/controlcenter
# Ingress/ingress-controlcenter

# KafkaTopic/shoe-customers
# KafkaTopic/shoe-products
# KafkaTopic/shoe-orders

export MANIFEST_DIR=./manifests/basic

deploy_manifests ${MANIFEST_DIR}