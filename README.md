# Local workstation Confluent demo (with Flink)

## Architecture

This runs a small Confluent Platform cluster on a local workstation, using Docker Desktop and the local Kubernetes

There are two versions:

1. 'basic' mode - has TLS but no authN or authZ
1. 'oidc' mode - uses OIDC/OAuth2.0 (Keycloak) for authentication, is maybe 40% functionally complete
    * Does not yet include CMF authentication/authorization, or Flink SQL, or CSFLE

Neither one has a complete 'demo' but should mostly work in getting all the components up and running.

Functionally, this will deploy the following:

* Ingress NGINX Controller (should probably be replaced with Gateway API)
* Keycloak pod (in oidc mode)
* Confluent for Kubernetes (CFK)
* CFK CRs:
    * 1x KRaft
    * 3x Kafka
    * 1x Schema Registry
    * 1x Connect
    * 1x Control Center (2.x i.e. "Next Gen")
* Flink Kubernetes Operator (FKO)
* Confluent Manager for Apache Flink (CMF)
* CMF CRs:
    * 1x FlinkEnvironment
    * 1x FlinkApplication
 
Instructions:

* Install Docker Desktop
* Enable Docker Desktop's built-in Kubernetes (I'm using KIND, but Kubeadm should also work)
* Configure Docker Desktop with at least 6 cores and 16 GB of memory
* Install the following:
    * `brew`
    * `openssl`
    * `helm`
    * `cfssl` - Used for certificate generation

## Start Here

Go to one of these two docs to install everything

Basic Mode - moderately feature complete
* [Basic Mode Installation](./docs/basic/01-deploy.md)
* [Basic Mode CSFLE Demo](./docs/basic/02-data-governance.md)
* [Basic Mode CP Flink SQL Demo](./docs/basic/03-flink-sql-demo.md)

OIDC Mode - WIP
* [OIDC Mode Installation](./docs/oidc/01-deploy.md)
