#!/bin/bash

# set -e
# set -x

. ./versions.sh
. ./functions.sh

# From manifests
kubectl -n ${NAMESPACE} delete \
    service/ldap \
    statefulset/ldap

# Manually created (none)