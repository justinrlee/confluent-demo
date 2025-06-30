#!/bin/bash

set -e
# set -x

. ./versions.sh
. ./functions.sh

RESOURCES=$(kubectl api-resources --namespaced=true -oname --verbs=get | grep -v event)

for R in ${RESOURCES[@]};
do 
# echo ${R}
kubectl get ${R} -n ${NAMESPACE} -oname
done

echo "--------"

echo "This doesn't currently delete anything, just list all items in the namespace"