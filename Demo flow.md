# Kubernetes demo

# Description
In this demo I'll show you how to create a Postgres cluster with CloudNativePG kubernetes operator. The features that I want to show you are:
- Kubernetes plugin install
- CloudNativePG operator install
- Postgres cluster install
- Insert data in the cluster
- Switchover (promote)
- Failover
- Backup
- Recovery
- Rolling updates (minor and major)

# Prerequisites
- K8s environment
- Tested with Docker Desktop with Kubernetes on Mac 


## Demo prep

### Find IP address of this machine


```
ipconfig getifaddr en0
ipconfig getifaddr en6`
```
Enter this IP address in mycluster-upgrade.yaml

### Start Minio

```
kubectl create secret generic minio-creds \
  --from-literal=MINIO_ACCESS_KEY=admin \
  --from-literal=MINIO_SECRET_KEY=password

docker run -p 9000:9000 -p 9001:9001 \
           -e MINIO_ROOT_USER=admin \
           -e MINIO_ROOT_PASSWORD=password \
           -d --rm \
           minio/minio server /data \
           --console-address ":9001"`
```

## Configuration

### Install plugin

```
curl -sSfL https://github.com/cloudnative-pg/cloudnative-pg/raw/main/hack/install-cnpg-plugin.sh | sh -s -- -b /usr/local/bin
```
### Install operator

```
version1=`kubectl-cnpg version | awk '{ print $2 }' | awk -F":" '{ print $2}'`
version2=${version1%??}
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-$version2/releases/cnpg-$version1.yaml`
```
### Check operator installed

```
kubectl get deploy -n cnpg-system cnpg-controller-manager -o wide
```

## Create cluster

### Install cluster

```
cat mycluster.yaml
```

```
kubectl apply -f mycluster.yaml
```

```
kubectl get pods
```

### Show status

```
watch -c -n 1 kubectl-cnpg status mycluster
```

### Insert data

```
cat sqltest.sql
```

```
kubectl exec -i mycluster-1 -- psql < sqltest.sql
```

### Check data

```
kubectl exec -it mycluster-2 -- psql -c "select * from test limit 15;"

kubectl exec -it mycluster-2 -- psql -c "select count(*) from test;"
```

## Promotion 

### Promotion of node 2 to Primary

```
kubectl-cnpg promote mycluster mycluster-2
```

## In-place rolling upgrade minor version

### Update from Postgres 14.2 to 14.5

```
cat mycluster-upgrade.yaml
```

```
kubectl apply -f mycluster-upgrade.yaml`
```
## Backup & restore

### Open the Minio console

```
open http://localhost:9001
```

### Backup cluster

```
cat backup.yaml
```

```
kubectl apply -f backup.yaml
```

### Verify backup

```
kubectl describe backup mybackup
```

### Restore to new cluster

```
cat restore.yaml
```
```
kubectl exec -it mycluster-2 -- psql -c "select pg_switch_wal();"
kubectl apply -f restore.yaml
```

### Verify restore

```
watch -c -n 1 kubectl-cnpg status mycluster-restore
```
```
kubectl exec -it mycluster-restore-1 -- psql -c "select * from test limit 15;"
```
```
kubectl exec -it mycluster-restore-1 -- psql -c "select count(*) from test;"
```

## Failover 

### Delete Primary pod


```
kubectl delete pod mycluster-2 --force
```

```
watch -c -n 1 kubectl-cnpg status mycluster
```

## Migration major version

### Create Postgres 13 cluster


```
kubectl apply -f cluster-example-13.yaml
```

```
watch -c -n 1 kubectl-cnpg status cluster-example-13
```

### Add data to cluster


```
kubectl exec -it cluster-example-13-1 -- psql app < sqltest.sql
```

### Verify inserted data


```
kubectl exec -it cluster-example-13-1 -- psql app -c "select * from test limit 15;"
```


```
kubectl exec -it cluster-example-13-1 -- psql app -c "select count(*) from test;" app
```

### Create new Postgres 15 cluster based on Postgres 13 cluster


```
kubectl apply -f cluster-example-upgrade-13-to-15.yaml
```

### Verify data in new cluster


```
kubectl exec -it cluster-example-15-1 -- psql app -c "select * from test limit 15;"
```


```
kubectl exec -it cluster-example-15-1 -- psql app -c "select count(*) from test;"
```

# End of demo

## How to deploy and access the Kubernetes Dashboard


```
./dashboard_install.sh
```

# Links
[https://github.com/minio/minio](https://github.com/minio/minio)

[https://cloudnative-pg.io](https://cloudnative-pg.io)

# Cleanup


```
kubectl delete backup mybackup
kubectl delete deployments.apps -n cnpg-system cnpg-controller-manager
version1=`kubectl-cnpg version | awk '{ print $2 }' | awk -F":" '{ print $2}'`
version2=${version%??}
kubectl delete -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-$version2/releases/cnpg-$version1.yaml
kubectl delete secret minio-creds
docker ps | grep minio | awk '{print $1}' | xargs -I % docker stop %
kubectl delete cluster mycluster-13
kubectl delete cluster mycluster-15
kubectl delete cluster mycluster
kubectl delete cluster mycluster-restore
docker pull ghcr.io/cloudnative-pg/postgresql:13
docker pull ghcr.io/cloudnative-pg/postgresql:14.2
docker pull ghcr.io/cloudnative-pg/postgresql:14.5
docker pull ghcr.io/cloudnative-pg/postgresql:15.1
```

## Uninstall Kubernetes Dashboard

```
./dashboard_uninstall.sh
```
