#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

###### Install Infra
# Namespace: confluent-demo
# Namespace: ingress-nginx
# Helm: Ingress NGINX
# Helm: CFK
# Certs:
    # kraft
    # kafka
    # connect
    # controlcenter
    # schemaregistry
    # client
# Secrets
    # tls-client-full
    # mds-token
# Waits
./deploy/infra.sh

###### Deploy confluent-utility container and configmap
./deploy/utility.sh

###### Deploy basic CFK manifests
# KRaftController/kraft

# Kafka/kafka
# Ingress/kafka
# Service/kafka-bootstrap
# KafkaRestClass/default

# SchemaRegistry/schemaregistry
# Ingress/schemaregistry

# Connect/connect

# ControlCenter/controlcenter
# Ingress/controlcenter

# KafkaTopic/shoe-customers
# KafkaTopic/shoe-products
# KafkaTopic/shoe-orders
./deploy/basic/cp.sh

###### Deploy CMF and FKO
# Helm: FKO
# Helm: CMF - depends on CFK
# Secrets
    # cmf-encryption-key
    # tls-cmf-service
    # tls-cmf-full
# Manifests
    # FlinkApplication/state-machine-example
    # FlinkEnvironment/confluent-demo
./deploy/basic/cpf.sh

###### Deploy connectors
# * shoe-customers
# * shoe-products
# * shoe-orders
./deploy/basic/connectors.sh

###### Deploy Vault
# Namespace: vault
# Helm: vault
# Manifest: Ingress/vault
# Enable transit secret engine and create key
./deploy/vault.sh

set +x
check_for_readiness