#!/bin/bash

set -e
set -x

. ./versions.sh
. ./functions.sh

export MANIFEST_DIR=./manifests/oidc

tee ${LOCAL_DIR}/oauth_jaas.txt <<-'EOF'
clientId=kafka
clientSecret=LpXqoU8bqCqXgNsPKAJIJhQ9WafgWwsj
EOF

tee ${LOCAL_DIR}/sso_oauth_jaas.txt <<-'EOF'
clientId=confluent-sso
clientSecret=Wyt2jq5gzqrONotJ4W7R07OA4yUnnj3l
EOF

kubectl create -n ${NAMESPACE} secret generic \
    oauth-jaas \
    --from-file=oauth.txt=${LOCAL_DIR}/oauth_jaas.txt \
    --from-file=oidcClientSecret.txt=${LOCAL_DIR}/oauth_jaas.txt \
    --dry-run=client -oyaml --save-config \
    > ${LOCAL_DIR}/oauth-jaas.yaml
kubectl apply -f ${LOCAL_DIR}/oauth-jaas.yaml

kubectl create -n ${NAMESPACE} secret generic \
    sso-oauth-jaas \
    --from-file=oauth.txt=${LOCAL_DIR}/sso_oauth_jaas.txt \
    --from-file=oidcClientSecret.txt=${LOCAL_DIR}/sso_oauth_jaas.txt \
    --dry-run=client -oyaml --save-config \
    > ${LOCAL_DIR}/sso-oauth-jaas.yaml
kubectl apply -f ${LOCAL_DIR}/sso-oauth-jaas.yaml

deploy_manifests ${MANIFEST_DIR}

wait_for_c3