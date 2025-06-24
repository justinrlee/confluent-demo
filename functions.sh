#!/bin/bash

. ./versions.sh

wait_for_c3 () {
while [[ $(kubectl -n ${NAMESPACE} get pods -l app=controlcenter | grep '3/3' | wc -l) -lt 1 ]];
do
    echo "Waiting for ControlCenter pod to be ready"
    kubectl -n ${NAMESPACE} get pods
    echo ''
    sleep 5
done
echo 'Access at "https://confluent.127-0-0-1.nip.io"'
}