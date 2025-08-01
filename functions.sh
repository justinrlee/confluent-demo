#!/bin/bash

. ./.env

# If a resource has a deletionTimestamp, remove finalizers and delete it
# Sample Usage (either should work):
    # remove_if_deleted Secret mds-token
    # remove_if_deleted Secret/mds-token
remove_if_deleted () {
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

# Usage:
# wait_for_pod <LABEL> [<POD_COUNT_OVERRIDE> [<NAMESPACE_OVERRIDE>]]
# e.g.
# wait_for_pod app=schemaregistry
# wait_for_pod app=kafka 3
# wait_for_pod app.kubernetes.io/name=ingress-nginx 1 ingress-nginx
wait_for_pod () {
    export LABEL_SELECTOR=${1}
    export POD_COUNT=${2:-1}
    export NS=${3:-${NAMESPACE}}

    echo "Waiting for ${POD_COUNT} pods with the label ${LABEL_SELECTOR} to be ready in namespace ${NS}"

    while [[ $(kubectl -n ${NS} get pods -l ${LABEL_SELECTOR} | grep "1/1" | grep "Running" | wc -l ) -lt ${POD_COUNT} ]]; 
    do
        clear
        echo "Waiting 5s for ${POD_COUNT}x pods with label ${LABEL_SELECTOR} to be ready..."
        echo "Filtered pods:"
        kubectl -n ${NS} get pods -l ${LABEL_SELECTOR}
        echo ""
        echo "All pods:"
        kubectl -n ${NS} get pods
        echo ""
        echo "Logs:"
        kubectl -n ${NS} logs -l ${LABEL_SELECTOR} --tail 5 || true
        echo ""
        sleep 5
    done

}

# special behavior to account for 3/3 containers in the pod
wait_for_c3 () {
    while [[ $(kubectl -n ${NAMESPACE} get pods -l app=controlcenter | grep '3/3' | grep "Running" | wc -l) -lt 1 ]];
    do
        clear
        echo "Waiting 5s for ControlCenter pod to be ready..."
        echo "Filtered pods:"
        kubectl -n ${NAMESPACE} get pods -l app=controlcenter
        echo ""
        echo "All pods":
        kubectl -n ${NAMESPACE} get pods
        echo ""
        echo "Logs:"
        kubectl -n ${NAMESPACE} logs -l app=controlcenter -c controlcenter --tail 10 || true
        echo ""
        sleep 5
    done
}

restart_if_not_ready () {
    if [[ $(kubectl -n ${NAMESPACE} get pod ${1} | grep "1/1" | grep "Running" | wc -l ) -lt 1 ]];
    then
        echo "Restarting pod ${1} in namespace ${NAMESPACE}"
        kubectl -n ${NAMESPACE} delete pod ${1} || true
    fi
}

check_for_readiness () {
    wait_for_pod app=kraft
    # wait_for kraft 1
    wait_for_pod app=kafka 3
    # wait_for kafka 3

    # Once Kafka is ready, restart all dependent pods, which are often in a crashloop at this points
    clear
    echo "Kafka cluster ready, restarting dependent pods..."
    restart_if_not_ready schemaregistry-0
    restart_if_not_ready connect-0
    restart_if_not_ready controlcenter-0
    wait_for_pod app=schemaregistry
    # wait_for schemaregistry 1
    # Connect takes forever to start, and is not actually necessary for the C3 UI to come up
    # wait_for connect 1
    wait_for_c3
    clear
    kubectl -n ${NAMESPACE} get pod
    echo ""
    echo "Demo is ready!"
    echo "Access Confluent Control Center at 'https://confluent.${BASE_DOMAIN}'"
    echo 'Exec into utility pod with `./tools/shell.sh`'
}

clean_up_flinkdeployment () {
    while [[ $(kubectl -n ${NAMESPACE} get FlinkDeployment -oname | wc -w ) -gt 0 ]]; 
    do
        echo ""
        kubectl -n ${NAMESPACE} get FlinkDeployment
        echo "Waiting 2s for FlinkDeployments to be removed ..."
        sleep 2
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