#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

./deploy_infra.sh
./deploy_infra_keycloak.sh
./deploy_oidc_demo.sh
./deploy_flink_oidc.sh

wait_for_c3