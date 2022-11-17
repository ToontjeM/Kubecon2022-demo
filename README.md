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
- Last CloudNativePG tested version is 1.17.0

# Prerequisites
- K8s environment
- Tested with Docker Desktop with Kubernetes on Mac 

## Set up environment

1. Set up 3 panes in a vertical layout (Operator, Status and Minio)
2. Check IP address and enter in `cluster-example-upgrade.yaml`
3. Run Minio in pane 4 and minimize that pane
4. Open browser [http://localhost:9001](http://192.168.0.102:9000) - admin / password
5. (optional) Open VSCode in the `kubecon2022-demo` directory.

## Start demo

1. Run script 01-05 in pane 1.
2. Run script 06 in pane 3
3. Point out cluster nodes
4. Point out Primary instance
5. Point out Postgres version
6. Point out WAL file
7. Run script 07
    1. Show command
    2. Point out LSN’s have been updated
    3. Show `check_data.sh cluster-example` to show 1000 rows.

## Promotion

1. Run script 08
2. “Going to take -1 down so it will promote -2 to be primary”
3. Point out on the status screen. Maybe point out in pane 4 with `kubectl get pods`

## In-place version upgrade

1. Run script 09
2. Explain “We are going to perform an in-place upgrade from 14.2 to 14.5”
3. Show `cluster-example-upgrade.yaml` (keep it on screen for script 10)
4. Show status and wait for cluster to get into a healthy state

## Backup & Restore

1. Script 10 (Backup)
2. Open browser [http://192.168.0.102:9000](http://192.168.0.102:9000) - admin / password
3. Show backup section in `cluster-sample-upgrade.yaml`
4. If you want to see what that backup configuration looked like, run script 11 (`kubectl describe backup backup-test`) and focus on “backup completed”.
5. Script 12 (Restore)
    1. Show `restore.yaml`
    2. Run script 12
    3. Show in a separate pane using `watch -c -n 1 kubectl-cnpg status cluster-restore`
    4. Show `check_data.sh cluster-example` to contain 1000 rows.

## Failover

1. Script 13 (Failover)
    1. We are going to force delete a pod and see what happens.
    2. `kubectl delete pod <primary pod> --force`
    3. Show in status that cluster is failing over.

## Upgrade across clusters

1. Run vsCode and connect to server
2. Open script 20 and `cluster-example-13.yaml`
    1. Emphasise on bootstrap
3. Insert data using script 21
    1. Show script
    2. Show SQL
4. Run script 22 
    1. “To make sure that all our data is in there”
    2. Show script
    3. Emphasise on SQL
5. Show script 23
    1. Show yaml file
    2. Explain that we are getting the cluster and all its data from the external source cluster.
    3. Run `kubectl-cnpg status cluster-example-14` or `15`
6. Show and run script 24 (Validate)


To delete your cluster execute:
```
./delete_all_clusters.sh
```

If you want to delete and create your Kind and K3d clusters and pull the PostgreSQL images from Docker to Kind or/and K3d, execute this script:
```
# Warning: script adapted for K3d
./99_remove_cluster.sh
```

# How to deploy and access the Kubernetes Dashboard
```
./dashboard_install.sh
```
# Uninstall Kubernetes Dashboard
```
./dashboard_uninstall.sh
```

# Useful commands
```
./get_ip.sh
```
Links

[https://github.com/minio/minio](https://github.com/minio/minio)

