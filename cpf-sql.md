```bash
CONFLUENT_CMF_CERTIFICATE_AUTHORITY_PATH=/root/certs/ca.crt
CONFLUENT_CMF_URL=http://cmf-service.confluent-demo.svc.cluster.local

# export NAMESPACE=confluent-demo

confluent flink environment list

# confluent flink --environment ${CMF_ENVIRONMENT_NAME} compute-pool create pool.json
confluent flink --environment ${CMF_ENVIRONMENT_NAME} compute-pool create pool-with-secrets.json
confluent flink --environment ${CMF_ENVIRONMENT_NAME} compute-pool list

kafka-broker-api-versions --bootstrap-server kafka.confluent-demo.svc.cluster.local:9071 --command-config client.properties

curl \
  -H 'content-type: application/json' \
  -X POST \
  ${CONFLUENT_CMF_URL}/cmf/api/v1/secrets \
  -d@secret-kafka.json

curl \
  -H 'content-type: application/json' \
  -X POST \
  ${CONFLUENT_CMF_URL}/cmf/api/v1/secrets \
  -d@secret-schemaregistry.json

# Get secrets
curl ${CONFLUENT_CMF_URL}/cmf/api/v1/secrets | jq '.'

curl \
  -H 'content-type: application/json' \
  -X POST \
  ${CONFLUENT_CMF_URL}/cmf/api/v1/environments/${CMF_ENVIRONMENT_NAME}/secret-mappings \
  -d@esm-kafka.json

curl \
  -H 'content-type: application/json' \
  -X POST \
  ${CONFLUENT_CMF_URL}/cmf/api/v1/environments/${CMF_ENVIRONMENT_NAME}/secret-mappings \
  -d@esm-schemaregistry.json

# Get secretmappings
curl ${CONFLUENT_CMF_URL}/cmf/api/v1/environments/${CMF_ENVIRONMENT_NAME}/secret-mappings | jq '.'

# Create catalog
confluent flink catalog create catalog.json

confluent flink catalog list

confluent --environment ${CMF_ENVIRONMENT_NAME} flink statement create ddl1 \
  --catalog demo --database kafka --compute-pool pool --output json \
  --sql "SHOW TABLES;"

confluent --environment ${CMF_ENVIRONMENT_NAME} --compute-pool pool flink shell
```


CONFLUENT_CMF_URL=http://cmf-service.confluent-demo.svc.cluster.local

```bash
tee client.properties <<-'EOF'
bootstrap.servers=kafka.confluent-demo.svc.cluster.local:9071
security.protocol=SSL
ssl.truststore.location=/root/certs/truststore.p12
ssl.truststore.password=confluent

key.converter.schema.registry.ssl.truststore.location=/root/certs/truststore.p12
key.converter.schema.registry.ssl.truststore.password=confluent
key.converter.schema.registry.url=https://schemaregistry.confluent-demo.svc.cluster.local:8081
value.converter.schema.registry.ssl.truststore.location=/root/certs/truststore.p12
value.converter.schema.registry.ssl.truststore.password=confluent
value.converter.schema.registry.url=https://schemaregistry.confluent-demo.svc.cluster.local:8081
EOF

tee pool.json <<-'EOF'
{
  "apiVersion": "cmf.confluent.io/v1",
  "kind": "ComputePool",
  "metadata": {
    "name": "pool"
  },
  "spec": {
    "type": "DEDICATED",
    "clusterSpec": {
      "flinkVersion": "v1_19",
      "image": "confluentinc/cp-flink-sql:1.19-cp1",
      "flinkConfiguration": {
        "pipeline.operator-chaining.enabled": "false",
        "execution.checkpointing.interval": "10s"
      },
      "taskManager": {
        "resource": {
          "cpu": 1.0,
          "memory": "1024m"
        }
      },
      "jobManager": {
        "resource": {
          "cpu": 1.0,
          "memory": "1024m"
        }
      }
    }
  }
}
EOF

tee pool-with-secrets.json <<-'EOF'
{
  "apiVersion": "cmf.confluent.io/v1",
  "kind": "ComputePool",
  "metadata": {
    "name": "pool"
  },
  "spec": {
    "type": "DEDICATED",
    "clusterSpec": {
      "flinkVersion": "v1_19",
      "image": "confluentinc/cp-flink-sql:1.19-cp1",
      "flinkConfiguration": {
        "pipeline.operator-chaining.enabled": "false",
        "execution.checkpointing.interval": "10s"
      },
      "taskManager": {
        "resource": {
          "cpu": 1,
          "memory": "1024m"
        }
      },
      "jobManager": {
        "resource": {
          "cpu": 1,
          "memory": "1024m"
        }
      },
      "podTemplate": {
        "spec": {
          "containers": [
            {
              "name": "flink-main-container",
              "volumeMounts": [
                {
                  "name": "tls-client",
                  "mountPath": "/mnt/certs"
                }
              ]
            }
          ],
          "volumes": [
            {
              "name": "tls-client",
              "secret": {
                "secretName": "tls-client-full"
              }
            }
          ]
        }
      }
    }
  }
}
EOF

tee secret-kafka.json <<-'EOF'
{
  "apiVersion": "cmf.confluent.io/v1",
  "kind": "Secret",
  "metadata": {
    "name": "kafka"
  },
  "spec": {
    "data": {
        "security.protocol": "SSL",
        "ssl.truststore.location": "/mnt/certs/truststore.p12",
        "ssl.truststore.password": "confluent"
    }
  }
}
EOF

tee secret-schemaregistry.json <<-'EOF'
{
  "apiVersion": "cmf.confluent.io/v1",
  "kind": "Secret",
  "metadata": {
    "name": "schemaregistry"
  },
  "spec": {
    "data": {
        "schema.registry.ssl.truststore.location": "/mnt/certs/truststore.p12",
        "schema.registry.ssl.truststore.password": "confluent",
        "ssl.truststore.location": "/mnt/certs/truststore.p12",
        "ssl.truststore.password": "confluent"
    }
  }
}
EOF

tee esm-kafka.json <<-'EOF'
{
  "apiVersion": "cmf.confluent.io/v1",
  "kind": "EnvironmentSecretMapping",
  "metadata": {
    "name": "kafka"
  },
  "spec": {
    "secretName": "kafka"
  }
}
EOF

tee esm-schemaregistry.json <<-'EOF'
{
  "apiVersion": "cmf.confluent.io/v1",
  "kind": "EnvironmentSecretMapping",
  "metadata": {
    "name": "schemaregistry"
  },
  "spec": {
    "secretName": "schemaregistry"
  }
}
EOF

tee catalog.json <<'EOF'
{
  "apiVersion": "cmf.confluent.io/v1",
  "kind": "KafkaCatalog",
  "metadata": {
    "name": "demo"
  },
  "spec": {
    "srInstance": {
      "connectionConfig": {
        "schema.registry.url": "https://schemaregistry.confluent-demo.svc.cluster.local:8081"
      },
      "connectionSecretId": "schemaregistry"
    },
    "kafkaClusters": [
      {
        "databaseName": "kafka",
        "connectionConfig": {
          "bootstrap.servers": "kafka.confluent-demo.svc.cluster.local:9071"
        },
        "connectionSecretId": "kafka"
      }
    ]
  }
}
EOF
```