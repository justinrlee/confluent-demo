#!/bin/bash

. ./.env

# If a resource has a deletionTimestamp, remove finalizers and delete it
# Sample Usage (either should work):
    # delete_if_deleted Secret mds-token
    # delete_if_deleted Secret/mds-token
delete_if_deleted () {
    if [[ $(kubectl -n ${NAMESPACE} get $1 $2 -ojsonpath='{.metadata.deletionTimestamp}' | wc -c) -gt 0 ]];
    then
        echo "Removing finalizers for $1 $2"
        kubectl -n ${NAMESPACE} patch -p '{"metadata":{"finalizers":null}}' --type=merge $1 $2 $3
        echo "Deleting $1 $2"
        # Ignore set -e
        kubectl -n ${NAMESPACE} delete $1 $2 || true
        sleep 1
    fi
}

wait_for_c3 () {
    while [[ $(kubectl -n ${NAMESPACE} get pods -l app=controlcenter | grep '3/3' | grep "Running" | wc -l) -lt 1 ]];
    do
        echo "Waiting for ControlCenter pod to be ready..."
        kubectl -n ${NAMESPACE} get pods
        echo ''
        sleep 10
    done
    echo 'Access at "https://confluent.127-0-0-1.nip.io"'
}

wait_for_cfk () {
    while [[ $(kubectl -n ${OPERATOR_NAMESPACE} get pods -l app=confluent-operator | grep "1/1" | grep "Running" | wc -l ) -lt 1 ]]; 
    do
        echo "Waiting for CFK to be ready..."
        sleep 10
    done
}

wait_for_nginx () {
    while [[ $(kubectl -n ${INGRESS_NGINX_NAMESPACE} get pods -l app.kubernetes.io/name=ingress-nginx | grep "1/1" | grep "Running" | wc -l ) -lt 1 ]]; 
    do
        echo "Waiting for CFK to be ready..."
        sleep 10
    done
}

wait_for () {
    while [[ $(kubectl -n ${NAMESPACE} get pods -l app=${1} | grep "1/1" | grep "Running" | wc -l ) -lt ${2} ]]; 
    do
        echo "Waiting for ${1} to be ready..."
        echo "Filtered pods:"
        kubectl -n ${NAMESPACE} get pods -l app=${1}
        echo "All pods:"
        kubectl -n ${NAMESPACE} get pods
        echo ""
        sleep 5
    done
}

wait_for_keycloak() {
    while [[ $(kubectl -n ${KEYCLOAK_NAMESPACE} get pods -l app=keycloak | grep "1/1" | grep "Running" | wc -l ) -lt 1 ]]; 
    do
        echo "Waiting for Keycloak to be ready..."
        kubectl -n ${KEYCLOAK_NAMESPACE} get pods
        sleep 10
    done
}

restart_if_not_ready () {
    if [[ $(kubectl -n ${NAMESPACE} get pod ${1} | grep "1/1" | grep "Running" | wc -l ) -lt 1 ]];
    then
        kubectl -n ${NAMESPACE} delete pod ${1} || true
    fi
}

check_for_readiness () {
    wait_for kraft 1
    wait_for kafka 3

    # Once Kafka is ready, restart all dependent pods, which are often in a crashloop at this points
    restart_if_not_ready schemaregistry-0
    restart_if_not_ready connect-0
    restart_if_not_ready controlcenter-0
    wait_for schemaregistry 1
    # Connect takes forever to start, and is not actually necessary for the C3 UI to come up
    # wait_for connect 1
    wait_for_c3
}

clean_up_flinkdeployment () {
    while [[ $(kubectl -n ${NAMESPACE} get FlinkDeployment -oname | wc -w ) -gt 0 ]]; 
    do
        echo "Waiting for FlinkDeployments to be removed ..."
        kubectl -n ${NAMESPACE} get FlinkDeployment
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