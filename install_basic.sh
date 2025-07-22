#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

./deploy/infra.sh
./deploy/basic/cp.sh
./deploy/basic/cpf.sh

check_for_readiness