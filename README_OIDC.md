# OIDC Mode

## Check Prerequisites

```bash
./check_prereqs.sh
```

If using Orbstack, use this:

```bash
./check_orbstack_prereqs.sh
```

## Installation: OIDC Demo (Recommended)

Deploy infrastructure (Keycloak, CFK, CMF, FKO, Ingress-NGINX Ingress Controller, various certificates)

```bash
./install_oidc.sh
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
./remove_oidc.sh
```

## TODO

TODO (OIDC Infra)
* Fix OIDC for KafkaRestClass for KafkaTopics
* Get OIDC working for CMF
* Use distinct credentials for each service
* add FlinkEnvironment/FlinkApplication authentication/authorization
* ~~rename 'cmf-rbac' to 'cmf-oidc'~~
* Support remote installation

TODO Demo
* Flink compute pool, catalog, statements
* Add connectors (and plugins) - shoe store
* Add real Flink job
* ... other demo things?