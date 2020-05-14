# nodehack

A container image and Kubernetes DaemonSet to install a CA root certificate and
configure a nameserver on hosts for development and testing purposes.


## Dynamic CA registration in the container runtime

To make a container runtime aware of a new CA root certificate it has to be restarted.
At the time of writing only [CRI-O](https://github.com/cri-o/cri-o) supports
reloading CA certificates without terminating pods.


## script usage

```
nodehack HOSTPATH COMMAND...
```

`HOSTPATH` points to the host's file system that should be manipulated.

**Commands**
* `setca`: installs the CA certificate located in `CERT_FILE`.
* `setdns`: configures `NAMESERVER` as first nameserver.
* `reloadcrio`: sends `CRIO_RELOAD_SIGNAL` (default: 1) to the `crio` process if it exists.
* `restartcrio`: restarts CRI-O.
* `setready`: touches `/tmp/ready` - to be used as readiness probe.
* `sleepinfinity`: sleeps forever.
* other commands are resolved using the container's `PATH`.


## Deploy in Kubernetes

This repository also provides a kustomization containing a `DaemonSet`
that runs the script on every node with the host's file system mounted into it.  

It expects the CA secret `selfsigned-ca` to exist within the same namespace as the `DaemonSet`
and configures CoreDNS' static IP `10.96.0.10` as first nameserver on the host.  

It can be deployed within the current namespace as follows:
```
kubectl apply -k github.com/mgoltzsche/nodehack/deploy
```
