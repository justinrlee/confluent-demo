Right now this uses LDAP, which doesn't work with CMF, so CMF is currently unauthenticated.

TODO - Deployment:
* See if we can remove operator superuser
* Switch all components to distinct credentials
    * SchemaRegistry
    * KRaft
    * C3ng
* C3ng
    * Enable CMF (currently disabled)
* Connect - add plugins
* Remove cert-manager
* enable SSL for CMF
* Deploy FKO (and cert-manager? or do it manually)

ToDo: Demo:
* What should this consist of?

Done:
* KRaft (1)
* Kafka (3)
* SchemaRegistry