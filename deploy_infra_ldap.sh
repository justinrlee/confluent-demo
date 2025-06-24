#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

# Depends on ingress-nginx
deploy_manifests ./manifests/ldap