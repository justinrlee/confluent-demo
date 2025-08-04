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
    # mds-token
# Waits
./deploy/01_nginx.sh
./deploy/02_vault.sh
./deploy/03_cfk.sh
./deploy/04_utility.sh
./deploy/05_keycloak.sh
./deploy/10_cp_oidc.sh
./deploy/11_cpf_oidc.sh

./deploy/20_topics.sh
./deploy/21_connectors.sh

wait_for_pod app=keycloak 1 ${KEYCLOAK_NAMESPACE}
restart_if_not_ready kafka-0
restart_if_not_ready kafka-1
restart_if_not_ready kafka-2
check_for_readiness