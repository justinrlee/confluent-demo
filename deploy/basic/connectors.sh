#!/bin/bash

set -e
set -x

. ./.env
. ./functions.sh

###### manifests/basic includes these objects:

export MANIFEST_DIR=./manifests/connectors/basic

deploy_manifests ${MANIFEST_DIR}