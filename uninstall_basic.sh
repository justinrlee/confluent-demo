#!/bin/bash

./cleanup/vault.sh
./cleanup/basic/cmf_children.sh
./cleanup/basic/connectors.sh
./cleanup/basic/cpf.sh
./cleanup/basic/cp.sh
./cleanup/basic/configmap.sh
./cleanup/infra.sh