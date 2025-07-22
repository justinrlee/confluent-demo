#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

./deploy/infra.sh
./deploy/keycloak.sh
./deploy/oidc/cp.sh
./deploy/oidc/cpf.sh

wait_for_c3