#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

./deploy/infra.sh
./deploy/basic/cp.sh
./deploy/basic/cpf.sh

wait_for_c3