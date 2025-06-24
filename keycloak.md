Create realm: confluent
Switch to realm (make sure top left says confluent 'current realm')

Clients:
* kafka
    * General:
        * Client type: OpenID Connect
        * Client ID: kafka
    * Capability config:
        * Client authentication: enabled
        * Authorization: enabled
        * Standard flow: checked
        * Direct access grants: checked
        * OAuth 2.0 Device Authorization Grant: checked
    * Get credentials (client ID and secret): `kafka`: `s9iqiL38PiT4nijygIHcEkAh3DGzVtUr`
    * Authorization > policies > delete default policy
* controlcenter
    * General:
        * Client type: OpenID Connect
        * Client ID: kafka
    * Capbility config:
        * Client authentication: enabled
        * Authorization: enabled
        * Standard flow: checked
        * Direct access grants: checked
        * OAuth 2.0 Device Authorization Grant: checked
    * Login Settings:
        * root url: https://confluent.127-0-0-1.nip.io
        * redirect uri: https://confluent.127-0-0-1.nip.io/api/metadata/security/1.0/oidc/authorization-code/callback
    * After creation, go to client scopes > `controlcenter-dedicated`
        * Configure a new mapper
        * Group Membership
        * Name: groups
        * Token Claim Name: `groups`
    * Get credentials (client ID and secret): `kafka`: `ybgv1OvI6wW3E5cDGRCmhC6JJNdq5ZaQ`
    * Authorization > policies > delete default policy

Groups: create group called `administrators`

Users: create user called `admin`, admin@example.com, admin, admin
    * Create password `admin` (not temporary)
    

create controlcenter client
client auth on
authorization on
standard flow
root url: https://confluent.127-0-0-1.nip.io
redirect uri: https://confluent.127-0-0-1.nip.io/api/metadata/security/1.0/oidc/authorization-code/callback

create group 'administrators'
create user 'admin' in group 'administrators' (admin@example.com)

For now, need a manual rolebinding that looks like this (username is UUID for Keycloak user that needs access)

```yaml
apiVersion: platform.confluent.io/v1beta1
kind: ConfluentRolebinding
metadata:
  name: manual-admin
  namespace: confluent-demo
spec:
  principal:
    name: 8b0e6985-da9a-49d2-9205-fcf4735c81f4
    type: user
  role: SystemAdmin
```

Add group mapper to 'controlcenter' client
go to client
go to client scopes
controlcenter-dedicated scope
add a mapper 'group membership'
token claim name: groups