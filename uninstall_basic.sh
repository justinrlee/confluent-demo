#!/bin/bash

# Reverse order of install_basic.sh
./destroy/30_cmf_children.sh
./destroy/21_connectors.sh
./destroy/20_topics.sh
./destroy/11_cpf_basic.sh
./destroy/10_cp_basic.sh
# ./destroy/05_keycloak.sh
./destroy/04_utility.sh
./destroy/03_cfk.sh
./destroy/02_vault.sh
./destroy/01_nginx.sh