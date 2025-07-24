#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

./deploy/infra.sh
./deploy/basic/cp.sh
./deploy/basic/cpf.sh

set +x
check_for_readiness