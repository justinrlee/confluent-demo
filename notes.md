# Test LDAP

From confluent-utility container:
ldapsearch -H ldap://ldap.confluent.svc.cluster.local:389 \
    -x \
    -D 'cn=admin,dc=confluent,dc=justinrlee,dc=io' \
    -w GoodNewsEveryone \
    -b 'dc=confluent,dc=justinrlee,dc=io'

# Need to update users to match pattern in ldapsearch (users and child users need to be in same org / same type)