# DB Cluster created using binami offical helm chart 
```
helm install mysql bitnami/mysql \
  --set auth.rootPassword=$MYSQL_ROOT_PASSWORD \
  --set auth.replicationPassword=$MYSQL_REPL_PASSWORD \
  -f mysql-values.yaml
```