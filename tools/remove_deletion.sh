
#!/bin/bash

set -e
# set -x

. ./.env
. ./functions.sh

kubectl -n ${NAMESPACE} patch -p '{"metadata":{"deletionGracePeriodSeconds":null}}' -v8 --type=merge $1 $2 $3
kubectl -n ${NAMESPACE} patch -p '{"metadata":{"deletionTimestamp":null}}' -v8 --type=merge $1 $2 $3