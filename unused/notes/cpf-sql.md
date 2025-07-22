CONFLUENT_CMF_URL=http://cmf-service.confluent-demo.svc.cluster.local

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

tee catalog.json <<'EOF'
{
  "apiVersion": "cmf.confluent.io/v1",
  "kind": "KafkaCatalog",
  "metadata": {
    "name": "catalog1"
  },
  "spec": {
    "srInstance": {
      "connectionConfig": {
        "schema.registry.url": "https://schemaregistry.confluent-demo.svc.cluster.local:8081"
      }
    },
    "kafkaClusters": [
      {
        "databaseName": "kafka-1",
        "connectionConfig": {
          "bootstrap.servers": "kafka-1:9092"
        },
        "connectionSecretId": "kafka-1-secret-id"
      },
      {
        "databaseName": "kafka-2",
        "connectionConfig": {
          "bootstrap.servers": "kafka-2:9092"
        }
      }
    ]
  }
}
EOF