# export CFK_CHART_VERSION=0.1193.47
# export CFK_INIT_CONTAINER_VERSION=2.11.1
# export CONFLUENT_PLATFORM_VERSION=7.9.1
# export CONTROL_CENTER_VERSION=2.1.0
# export INGRESS_NGINX_VERSION=4.10.6
# export CMF_VERSION=1.1.0
# export FKO_VERSION=1.120.1
export CFK_CHART_VERSION=0.1263.8
export CFK_INIT_CONTAINER_VERSION=3.0.0
export CONFLUENT_PLATFORM_VERSION=8.0.0
export CONTROL_CENTER_VERSION=2.2.0
export INGRESS_NGINX_VERSION=4.10.6
export CMF_VERSION=2.0.1
export FKO_VERSION=1.120.1

# Use confluent-demo namespace to not interfere with things in confluent namespace
export NAMESPACE=confluent-demo
export INGRESS_NGINX_NAMESPACE=ingress-nginx
export OPERATOR_NAMESPACE=confluent-demo
export FLINK_ENVIRONMENT_NAME=demo

export CMF_SERVICE_ACCOUNT=cmf-confluent-demo

export KEYCLOAK_NAMESPACE=keycloak

export LOCAL_DIR=./local
export CERT_DIR=./local/certs
export CFSSL_DIR=./local/cfssl