## Data Governance Demo (Basic Mode)

**This is currently only a very simple CSFLE demo**

After doing the initial deployment (instructions in [Basic Setup](./01-deploy.md)), you can run the Data Governance demo (currently only includes CSFLE)

Everything should be run from the utility pod, which has direct access to CFK and CMF from within the cluster.

You can exec into the pod with this:

```bash
kubectl -n confluent-demo exec -it confluent-utility-0 -- bash
```

(or use the helper script to get into the utility pod):

```bash
./tools/shell.sh
```

*Run from within the utility pod*

Verify the csfle Vault key was properly created (and auth works, etc.)

```bash
vault kv list transit/keys
```

Create basic schema:

```bash
# Create schema
tee schema.json <<-'EOF'
{
  "name": "PersonalData",
  "type": "record",
  "namespace": "demo",
  "fields": [
    {
      "name": "id",
      "type": "string"
    },
    {
      "name": "name",
      "type": "string",
      "confluent:tags": [
        "PII"
      ]
    },
    {
      "name": "birthday",
      "type": "string",
      "confluent:tags": [
        "PII"
      ]
    }
  ]
}
EOF

# Create encryption rule
tee encryptPII.json <<-'EOF'
{
  "name": "encryptPII",
  "kind": "TRANSFORM",
  "type": "ENCRYPT",
  "mode": "WRITEREAD",
  "tags": [
    "PII"
  ],
  "params": {
    "encrypt.kek.name": "csfle-hashicorp",
    "encrypt.kms.key.id": "http://vault.vault.svc.cluster.local:8200/transit/keys/csfle",
    "encrypt.kms.type": "hcvault",
    "encrypt.dek.expiry.days": 7
  },
  "onFailure": "ERROR,NONE"
}
EOF

jq -s '{
    schema: (.[0] | tojson),
    schemaType: "AVRO",
    ruleSet: {
        domainRules: [.[1]]
    }
}' schema.json encryptPII.json > csfle.json

# Create a topic
kafka-topics --bootstrap-server ${BS} --command-config config/client.properties --create --topic csfle --replication-factor=3

# Register the schema
curl \
    -k \
    -X POST \
    -H 'content-type:application/json' \
    ${SR}/subjects/csfle-value/versions \
    -d @csfle.json
```

In the UI (accessible at https://confluent.127-0-0-1.nip.io/), navigate to the `csfle` topic ((Direct Link)[https://confluent.127-0-0-1.nip.io/clusters/confluentplatform-demo/management/topics/csfle/message-viewer])

Open two terminals, and exec into the utility pod in both:


You can exec into the pod with this:

```bash
kubectl -n confluent-demo exec -it confluent-utility-0 -- bash
```

(or use the helper script to get into the utility pod):

```bash
./tools/shell.sh
```

In the first utility pod:

```bash
# See the schema (might be 6, depending on what else you've done)
curl -k ${SR}/subjects/csfle-value/versions/latest

export CSFLE_SCHEMA_ID=$(curl -k ${SR}/subjects/csfle-value/versions/latest | jq '.id')

kafka-avro-console-producer \
    --bootstrap-server ${BS} \
    --producer.config config/client.properties \
    --reader-config config/client.properties \
    --property schema.registry.url=${SR} \
    --property value.schema.id=${CSFLE_SCHEMA_ID} \
    --topic csfle
```

Enter one-line messages formatted like this (note that the console producer is sensitive to newlines, and may error out if you accidentally send an empty message by pressing enter too many times)
```json
{"id": "userid1", "name": "firstname lastname", "birthday": "01/01/2020"}
```

In another utility pod, start a genric consumer:

```bash
kafka-console-consumer \
    --bootstrap-server ${BS} \
    --consumer.config config/client.properties \
    --topic csfle \
    --from-beginning
```

In another utility pod, start an avro consumer:

```bash
kafka-avro-console-consumer \
    --bootstrap-server ${BS} \
    --consumer.config config/client.properties \
    --property schema.registry.url=${SR} \
    --formatter-config config/client.properties \
    --topic csfle \
    --from-beginning
```

In another utility pod, start an avro consumer, and remove the VAULT_TOKEN environment variable (to simulate lack of credentials to Vault)


```bash
unset VAULT_TOKEN
kafka-avro-console-consumer \
    --bootstrap-server ${BS} \
    --consumer.config config/client.properties \
    --property schema.registry.url=${SR} \
    --formatter-config config/client.properties \
    --topic csfle \
    --from-beginning
```