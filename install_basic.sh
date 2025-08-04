#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

###### Install NGINX
# Namespace: ingress-nginx
# Helm: Ingress NGINX
./deploy/01_nginx.sh

###### Deploy Vault
# Namespace: vault
# Helm: vault
# Manifest: Ingress/vault
# Enable transit secret engine and create key
./deploy/02_vault.sh

###### Install Infra
# Namespace: confluent-demo
# Helm: CFK
# Certs:
    # kraft
    # kafka
    # connect
    # controlcenter
    # schemaregistry
    # client
# Secrets
    # mds-token
# Waits
./deploy/03_cfk.sh

./deploy/04_utility.sh

# Keycloak is not part of the basic install
# ./deploy/05_keycloak.sh

./deploy/10_cp_basic.sh
./deploy/11_cpf_basic.sh

./deploy/20_topics.sh
./deploy/21_connectors.sh

check_for_readiness