#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

./deploy/infra.sh
./deploy/basic/configmap.sh
./deploy/basic/cp.sh
./deploy/basic/cpf.sh
./deploy/basic/connectors.sh
./deploy/vault.sh

set +x
check_for_readiness