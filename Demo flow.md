# Prepare environment
## Start Minio
kubectl create secret generic minio-creds \
  --from-literal=MINIO_ACCESS_KEY=admin \
  --from-literal=MINIO_SECRET_KEY=password

docker run -p 9000:9000 -p 9001:9001 \
           -e MINIO_ROOT_USER=admin \
           -e MINIO_ROOT_PASSWORD=password \
           -d --rm \
           minio/minio server /data \
           --console-address ":9001"
open http://localhost:9001

# Configuration
## Install plug-in
curl -sSfL https://github.com/cloudnative-pg/cloudnative-pg/raw/main/hack/install-cnpg-plugin.sh | sh -s -- -b /usr/local/bin

## Install operator
version1=`kubectl-cnpg version | awk '{ print $2 }' | awk -F":" '{ print $2}'`
version2=${version1%??}
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-$version2/releases/cnpg-$version1.yaml

## Check operator installed
kubectl get deploy -n cnpg-system cnpg-controller-manager -o wide

# Create cluster
## Install cluster
kubectl apply -f cluster-example.yaml

## Show status
watch -c -n 1 kubectl-cnpg status cluster-example

## Insert data
kubectl exec -i cluster-example-1 -- psql < sqltest.sql

## Check data
kubectl exec -it cluster-example-1 -- psql -c "select * from test limit 15;"
kubectl exec -it cluster-example-1 -- psql -c "select count(*) from test;"

# Promotion 
## Promotion of node 2 to Primary
kubectl-cnpg promote cluster-example cluster-example-2

# In-place rolling upgrade minor version
## Update from Postgres 14.2 to 14.5
kubectl apply -f cluster-example-upgrade.yaml

# Backup & restore
## Backup cluster
kubectl apply -f backup.yaml

## Verify backup
kubectl describe backup backup-test

## Restore to new cluster
kubectl apply -f restore.yaml

## Verify restore
watch -c -n 1 kubectl-cnpg status cluster-restore
kubectl exec -it cluster-restore-1 -- psql -c "select * from test limit 15;"
kubectl exec -it cluster-restore-1 -- psql -c "select count(*) from test;"

# Failover 
## Delete Primary pod
kubectl delete pod cluster-example-1 --force
watch -c -n 1 kubectl-cnpg status cluster-example

# Migration major version
## Create Postgres 13 cluster
kubectl apply -f cluster-example-13.yaml
watch -c -n 1 kubectl-cnpg status cluster-example-13

## Add data to cluster
kubectl exec -it cluster-example-13-1 -- psql app < sqltest.sql

## Verify inserted data
kubectl exec -it cluster-example-13-1 -- psql app -c "select * from test limit 15;"
kubectl exec -it cluster-example-13-1 -- psql app -c "select count(*) from test;" app

## Create new Postgres 15 cluster based on Postgres 13 cluster
kubectl apply -f cluster-example-upgrade-13-to-15.yaml

## Verify data in new cluster
kubectl exec -it cluster-example-15-1 -- psql app -c "select * from test limit 15;"
kubectl exec -it cluster-example-15-1 -- psql app -c "select count(*) from test;"

# End of demo
## Cleanup
kubectl delete backup backup-test
kubectl delete deployments.apps -n cnpg-system cnpg-controller-manager
version1=`kubectl-cnpg version | awk '{ print $2 }' | awk -F":" '{ print $2}'`
version2=${version%??}
kubectl delete -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-$version2/releases/cnpg-$version1.yaml
kubectl delete secret minio-creds
docker ps | grep minio | awk '{print $1}' | xargs -I % docker stop %
kubectl delete cluster cluster-example-13
kubectl delete cluster cluster-example-15
kubectl delete cluster cluster-example
kubectl delete cluster cluster-restore
docker pull ghcr.io/cloudnative-pg/postgresql:13
docker pull ghcr.io/cloudnative-pg/postgresql:14.2
docker pull ghcr.io/cloudnative-pg/postgresql:14.5
docker pull ghcr.io/cloudnative-pg/postgresql:15.1