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

# Demo flow
Demo flow is described in `Demo flow.md`

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
# Links

[https://github.com/minio/minio](https://github.com/minio/minio)

[https://cloudnative-pg.io](https://cloudnative-pg.io)
