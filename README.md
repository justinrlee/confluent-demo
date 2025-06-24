# THIS IS WIP

# Local workstation Confluent demo (with Flink)

This runs a small Confluent Platform cluster on a local workstation, using Docker Desktop and the local Kubernetes

There are two versions:

1. 'simple' mode - uses LDAP (OpenLDAP) for authentication/authorization, is maybe 80% functionally complete, although the demo needs to be fleshed out
2. 'oidc' mode - uses OIDC/OAuth2.0 (Keycloak) for authentication, is maybe 30% functionally complete

Architecturally, this will deploy:

* Ingress NGINX Controller (should probably be replaced with Gateway API)
* LDAP and/or Keycloak
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

* Install Docker Desktop, and enable built-in Kubernetes (I'm using KIND, but it shouldn't matter what type you use)
    * I've given Docker Desktop 6 cores and 16GB of memory; need to do testing to see how small we can trim this
* Install `brew`, `helm`, `openssl`, `cfssl`

Check prereqs:

```bash
./check_prereqs.sh
```

Install "infra" stuff

```bash
./install.sh
```

Deploy manifests

```bash
./deploy_simple_manifests.sh
```

Monitor pods as they come up (need Control Center to be 3/3); may take some time

```bash
kubectl -n confluent-demo get pods -w
```

(You can also monitor C3 logs with `kubectl -n confluent-demo logs -f controlcenter-0 -c controlcenter`)

Open up control center: https://confluent.127-0-0-1.nip.io/

Log in with `kafka`/`kafka-secret`

... Poke around?

WHen you're done, uninstall:

```bash
./uninstall.sh
```

 
TODO (Repo)
* lots of refactoring
    * rearrange installation / uninstallation scripts to use functions
* lots of documentation
* look at gateway API
* figure out how to remove cert-manager
* tune resources (requirements and limits) to work better locally

TODO (Simple)
* replace harcoded LDAP container with generic parameterized one
* use distinct credentials for different services (right now everything uses `kafka/kafka-secret`)

TODO (oidc)
* get everything else working
* get SSO working
* create other credentials
* automate keycloak
* add FlinkEnvironment/FlinkApplication authentication/authorization

TODO (demo)
* Add connectors (and plugins) - shoe store
* Add real FLink job
* ... other demo things?
