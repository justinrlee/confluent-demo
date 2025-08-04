# Local workstation Confluent demo (with Flink)

## Architecture

This runs a small Confluent Platform cluster on a local workstation, using Docker Desktop and the local Kubernetes

There are two versions:

1. 'basic' mode - has TLS but no authN or authZ
1. 'oidc' mode - uses OIDC/OAuth2.0 (Keycloak) for authentication, is maybe 80% functionally complete
    * Does not yet include CMF authentication/authorization, which I'm still trying to get working.

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

## TODO (Repo-level)

* Refactor
    * Combine prereq scripts
    * Combine install/uninstall scripts
    * Refactor certificate generation into function
* Look at jq or kustomize templating for basic vs. oidc
* Improve Documentation
* Look at Kubernetes Gateway API
* Data governance stuff
* Move CP CSFLE manifests to container
* Refactor to single:
    * utility
    * vault
    * connectors
    * topics
* ~~Move versions.sh > .env~~
* ~~rearrange installation / uninstallation scripts to use functions~~
* ~~Size CPU / Memory~~
* ~~Cleanup scripts~~
* ~~change startup detection~~
* ~~figure out how to remove cert-manager~~
* ~~Update to 8.0.0 (CP and CPF/CMF)~~
* ~~support orbstack~~
* ~~verify we remove cfk helm chart~~