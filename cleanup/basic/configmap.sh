#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

kubectl delete ConfigMap utility-config \
    -n ${NAMESPACE}