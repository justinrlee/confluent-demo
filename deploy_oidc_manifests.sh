#!/bin/bash

set -e
set -x

. versions.sh

export MANIFEST_DIR=./cfk/oidc
export LOCAL_DIR=./local

tee ${LOCAL_DIR}/oauth_jaas.txt <<-'EOF'
clientId=kafka
clientSecret=3N0TwKJgERjzbVFrQLTZOjmeVHt1B7Z9
EOF

kubectl create -n ${NAMESPACE} secret generic \
    oauth-jaas \
    --from-file=oauth.txt=${LOCAL_DIR}/oauth_jaas.txt \
    --from-file=oidcClientSecret.txt=${LOCAL_DIR}/oauth_jaas.txt \
    --dry-run=client -oyaml --save-config \
    > ${LOCAL_DIR}/oauth-jaas.yaml
kubectl apply -f ${LOCAL_DIR}/oauth-jaas.yaml

ls -1 ${MANIFEST_DIR}

for f in \
    $(ls -1 ${MANIFEST_DIR})
do
    echo ${f}
    envsubst < ${MANIFEST_DIR}/${f} > ${LOCAL_DIR}/${f}
    kubectl apply -f ${LOCAL_DIR}/${f}
done