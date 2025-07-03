# Local workstation Confluent demo (with Flink)

This runs a small Confluent Platform cluster on a local workstation, using Docker Desktop and the local Kubernetes

There are two versions:

1. 'oidc' mode - uses OIDC/OAuth2.0 (Keycloak) for authentication, is maybe 80% functionally complete
    * Does not yet include CMF authentication/authorization, which I'm still trying to get working.
1. 'ldap' mode - uses LDAP (OpenLDAP) for authentication/authorization, is maybe 50% functionally complete
    * To keep the root directory clean, I've moved the startup scripts for this to `ldap`, which means they currently don't work.

Neither one has a complete 'demo' but should mostly work in getting all the components up and running.

Functionally, this will deploy the following:

* Ingress NGINX Controller (should probably be replaced with Gateway API)
* LDAP and/or Keycloak pod
* Confluent for Kubernetes (CFK)
* CFK CRs:
    * 1x KRaft
    * 3x Kafka
    * 1x Schema Registry
    * 1x Connect
    * 1x Control Center (2.x i.e. "Next Gen")
* Certificate Manager (for Flink Kubernetes Operator)
* Flink Kubernetes Operator (FKO)
* Confluent Manager for Apache Flink (CMF)
* CMF CRs:
    * 1x FlinkEnvironment
    * 1x FlinkApplication
 
Instruction:

* Install Docker Desktop
* Enable Docker Desktop's built-in Kubernetes (I'm using KIND, but Kubeadm should also work)
* Configure Docker Desktop with at least 6 cores and 16 GB of memory
* Install the following:
    * `brew`
    * `openssl`
    * `helm`
    * `cfssl` - Used for certificate generation

### Check Prerequisites

```bash
./check_prereqs.sh
```

## Installation: OIDC Demo (Recommended)

Deploy infrastructure (CFK, CMF, FKO, Ingress-NGINX Ingress Controller, various certificates)

```bash
./install_oidc_all.sh
```

Monitor pods as they come up (need Control Center to have 3/3 running containers); this may take some time to start.

```bash
kubectl -n confluent-demo get pods -w
```

(You can also monitor C3 logs with `kubectl -n confluent-demo logs -f controlcenter-0 -c controlcenter`)

Open up the control center UI: https://confluent.127-0-0-1.nip.io/

Log in with `admin`/`admin`

... Poke around?


#### CLI Login

Exec into the confluent-utility-0 container:

```bash
kubectl -n confluent-demo exec -it confluent-utility-0 -- bash
```

Login:

```bash
confluent login --url https://kafka:8090 --certificate-authority-path certs/ca.crt  --no-browser
```

### Cleanup

```bash
./uninstall_oidc_all.sh
```

## TODO

TODO (Repo)
* ~~Update to 8.0.0 (CP and CPF/CMF)~~
* Get OIDC working for CMF
* lots of refactoring
    * rearrange installation / uninstallation scripts to use functions
    * paramaterize ldap namespace
* lots of documentation
* look at gateway API
* figure out how to remove cert-manager
* tune resources (requirements and limits) to work better locally

TODO (ldap)
* replace harcoded LDAP container with generic parameterized one
* use distinct credentials for different services (right now everything uses `kafka/kafka-secret`)

TODO (oidc)
* use distinct credentials for different services
* create other credentials
* automate keycloak
* add FlinkEnvironment/FlinkApplication authentication/authorization

TODO (demo)
* Add connectors (and plugins) - shoe store
* Add real Flink job
* ... other demo things?
* clean up cmf permissions