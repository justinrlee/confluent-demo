#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

./deploy/infra.sh
./deploy/keycloak.sh
./deploy/oidc/cp.sh
./deploy/oidc/cpf.sh

set +x
wait_for_keycloak
restart_if_not_ready kafka-0
restart_if_not_ready kafka-1
restart_if_not_ready kafka-2
check_for_readiness