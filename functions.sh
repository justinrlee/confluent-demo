#!/bin/bash

. ./versions.sh

wait_for_c3 () {
    while [[ $(kubectl -n ${NAMESPACE} get pods -l app=controlcenter | grep '3/3' | wc -l) -lt 1 ]];
    do
        echo "Waiting for ControlCenter pod to be ready..."
        kubectl -n ${NAMESPACE} get pods
        echo ''
        sleep 10
    done
    echo 'Access at "https://confluent.127-0-0-1.nip.io"'
}

# This shouldn't be used, cause it's not reliable
# wait_for_cert_manager () {
#     while [[ $(kubectl -n cert-manager get pods -l app.kubernetes.io/instance=cert-manager | grep '1/1' | wc -l) -lt 3 ]];
#     do
#         echo "Waiting for cert-manager pod to start..."
#         sleep 10
#     done

#     while [[ $(kubectl -n cert-manager logs --tail=-1 -l app.kubernetes.io/instance=cert-manager  | grep "success.*controller" | wc -l ) -lt 1 ]];
#     do
#         echo "Waiting for cert-manager to be ready..."
#         sleep 10
#     done

#     sleep 10
# }

wait_for_cfk () {
    while [[ $(kubectl -n ${OPERATOR_NAMESPACE} get pods -l app=confluent-operator | grep "1/1" | wc -l ) -lt 1 ]]; 
    do
        echo "Waiting for CFK to be ready..."
        sleep 10
    done
}

wait_for_nginx () {
    while [[ $(kubectl -n ${INGRESS_NGINX_NAMESPACE} get pods -l app.kubernetes.io/name=ingress-nginx | grep "1/1" | wc -l ) -lt 1 ]]; 
    do
        echo "Waiting for CFK to be ready..."
        sleep 10
    done
}

deploy_manifests () {
    mkdir -p ${LOCAL_DIR}

    export MANIFEST_DIR=${1}
    
    ls -1 ${MANIFEST_DIR} | grep yaml

    for f in \
        $(ls -1 ${MANIFEST_DIR} | grep yaml)
    do
        echo ${f}
        envsubst < ${MANIFEST_DIR}/${f} > ${LOCAL_DIR}/${f}
        kubectl apply -f ${LOCAL_DIR}/${f}
    done
}