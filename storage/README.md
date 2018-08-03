# CORD Storage charts

These charts implement persistent storage that is within Kubernetes.

See the Kubernetes documentation for background material on how persistent
storage works:

- [StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/)
- [PersistentVolume](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

Using persistent storage is optional during development, but should be
provisioned for and configured during production and realistic testing
scenarios.

## Local Directory

The `local-provisioner` chart creates
[local](https://kubernetes.io/docs/concepts/storage/volumes/#local) volumes on
specific nodes, from directories. As there are no enforced limits for volume
size and the node names are preconfigured, this chart is intended for use only
for development and testing.

Multiple directories can be specified in the `volumes` list - an example is
given in the `values.yaml` file of the chart.

The `StorageClass` created for all volumes is `local-directory`.

There is an ansible script that automates the creation of directories on all
the kubernetes nodes.  Make sure that the inventory name in ansible matches the
one given as `host` in the `volumes` list, then invoke with:

```shell
ansible-playbook -i <path to ansbible inventory> --extra-vars "helm_values_file:<path to values.yaml>" local-directory-playbook.yaml
```

## Local Provisioner

The `local-provisioner` chart provides a
[local](https://kubernetes.io/docs/concepts/storage/volumes/#local),
non-distributed `PersistentVolume` that is usable on one specific node.  It
does this by running the k8s [external storage local volume
provisioner](https://github.com/kubernetes-incubator/external-storage/tree/master/local-volume/helm/provisioner).

This type of storage is useful for workloads that have their own intrinsic HA
or redundancy strategies, and only need storage on multiple nodes.

This provisioner is not "dynamic" in the sense that that it can't create a new
`PersistentVolume` on demand from a storage pool, but the provisioner can
automatically create volumes as disks/partitions are mounted on the nodes.

To create a new PV, a disk or partition on a node has to be formatted and
mounted in specific locations, after which the provisioner will automatically
create a `PersistentVolume` for the mount. As these volumes can't be split or
resized, care must be taken to ensure that the correct quantity, types, and
sizes of mounts are created for all the `PersistentVolumeClaim`'s required to
be bound for a specific workload.

By default, two `StorageClasses` were created to differentiate between Hard
Disks and SSD's:

- `local-hdd`, which offers PV's on volumes mounted in `/mnt/local-storage/hdd/*`
- `local-ssd`, which offers PV's on volumes mounted in `/mnt/local-storage/ssd/*`

### Adding a new local volume on a node

If you wanted to add a new volume a node, you'd physically install a new disk
in the system, then determine the device file it uses. Assuming that it's a
hard disk and the device file is `/dev/sdb`, you might partition, format, and
mount the disk like this:

```shell
$ sudo parted -s /dev/sdb \
    mklabel gpt \
    mkpart primary ext4 1MiB 100%
$ sudo mkfs.ext4 /dev/sdb1
$ echo "/dev/sdb1 /mnt/local-storage/hdd/sdb1 ext4 defaults 0 0" | sudo tee -a /etc/fstab
$ sudo mount /mnt/local-storage/hdd/sdb1
```

Then check that the `PersistentVolume` is created by the `local-provisioner`:

```shell
$ kubectl get pv
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM                  STORAGECLASS     REASON    AGE
local-pv-2bfa2c43   19Gi       RWO            Delete           Available                          local-hdd                  6h

$ kubectl describe pv local-pv-
Name:              local-pv-2bfa2c43
Labels:            <none>
Annotations:       pv.kubernetes.io/provisioned-by=local-volume-provisioner-node1-...
Finalizers:        [kubernetes.io/pv-protection]
StorageClass:      local-hdd
Status:            Available
Claim:
Reclaim Policy:    Delete
Access Modes:      RWO
Capacity:          19Gi
Node Affinity:
  Required Terms:
    Term 0:        kubernetes.io/hostname in [node1]
Message:
Source:
    Type:  LocalVolume (a persistent volume backed by local storage on a node)
    Path:  /mnt/local-storage/hdd/sdb1
Events:    <none>
```

## Ceph deployed with Rook

[Rook](https://rook.github.io/) provides an abstraction layer for Ceph and
other distributed persistent data storage systems.

There are 3 Rook charts included with CORD:

- `rook-operator`, which runs the volume provisioning portion of Rook (and is a
  thin wrapper around the upstream [rook-ceph
  chart](https://rook.github.io/docs/rook/v0.8/helm-operator.html)
- `rook-cluster`, which defines the Ceph cluster and creates these
  `StorageClass` objects usable by other charts:
  - `cord-ceph-rbd`, dynamically create `PersistentVolumes` when a
    `PersistentVolumeClaim` is created. These volumes are only usable by a
    single container at a time.
  - `cord-cephfs`, a single shared filesystem which is mountable
    `ReadWriteMulti` on multiple containers via `PersistentVolumeClaim`. It's
    size is predetermined.
- `rook-tools`, which provides a toolbox container for troubleshooting problems
  with Rook/Ceph

To create persistent volumes, you will need to load the first 2 charts, with
the third only needed for troubleshooting and diagnostics.

### Rook Node Prerequisties

By default, all the nodes running k8s are expected to have a directory named
`/mnt/ceph` where the Ceph data is stored (the `cephDataDir` variable can be
used to change this path).

In a production deployment, this would ideally be located on it's own block
storage device.

There should be at least 3 nodes with storage available to provide data
redundancy.

### Loading Rook Charts

First, add the `rook-beta` repo to helm, then load the `rook-operator` chart
into the `rook-ceph-system` namespace:

```shell
cd helm-charts/storage
helm repo add rook-beta https://charts.rook.io/beta
helm dep update rook-operator
helm install --namespace rook-ceph-system -n rook-operator rook-operator
```

Check that it's running (it will start the `rook-ceph-agent` and
`rook-discover` DaemonSets):

```shell
$ kubectl -n rook-ceph-system get pods
NAME                                  READY     STATUS    RESTARTS   AGE
rook-ceph-agent-4c66b                 1/1       Running   0          6m
rook-ceph-agent-dsdsr                 1/1       Running   0          6m
rook-ceph-agent-gwjlk                 1/1       Running   0          6m
rook-ceph-operator-687b7bb6ff-vzjsl   1/1       Running   0          7m
rook-discover-9f87r                   1/1       Running   0          6m
rook-discover-lmhz9                   1/1       Running   0          6m
rook-discover-mxsr5                   1/1       Running   0          6m
```

Next, load the `rook-cluster` chart, which connects the storage on the nodes to
the Ceph pool, and the CephFS filesystem:

```shell
helm install -n rook-cluster rook-cluster
```

Check that the cluster is running - this may take a few minutes, and look for the
`rook-ceph-mds-*` containers to start:

```shell
$ kubectl -n rook-ceph get pods
NAME                                                  READY     STATUS      RESTARTS   AGE
rook-ceph-mds-cord-ceph-filesystem-7564b648cf-4wxzn   1/1       Running     0          1m
rook-ceph-mds-cord-ceph-filesystem-7564b648cf-rcvnx   1/1       Running     0          1m
rook-ceph-mgr-a-75654fb698-zqj67                      1/1       Running     0          5m
rook-ceph-mon0-v9d2t                                  1/1       Running     0          5m
rook-ceph-mon1-4sxgc                                  1/1       Running     0          5m
rook-ceph-mon2-6b6pj                                  1/1       Running     0          5m
rook-ceph-osd-id-0-85d887f76c-44w9d                   1/1       Running     0          4m
rook-ceph-osd-id-1-866fb5c684-lmxfp                   1/1       Running     0          4m
rook-ceph-osd-id-2-557dd69c5c-qdnmb                   1/1       Running     0          4m
rook-ceph-osd-prepare-node1-bfzzm                     0/1       Completed   0          4m
rook-ceph-osd-prepare-node2-dt4gx                     0/1       Completed   0          4m
rook-ceph-osd-prepare-node3-t5fnn                     0/1       Completed   0          4m

$ kubectl -n rook-ceph get storageclass
NAME            PROVISIONER                    AGE
cord-ceph-rbd   ceph.rook.io/block             6m
cord-cephfs     kubernetes.io/no-provisioner   6m

$ kubectl -n rook-ceph get filesystems
NAME                   AGE
cord-ceph-filesystem   6m

$ kubectl -n rook-ceph get pools
NAME             AGE
cord-ceph-pool   6m

$ kubectl -n rook-ceph get persistentvolume
NAME                CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM     STORAGECLASS   REASON    AGE
cord-cephfs-pv      20Gi       RWX            Retain           Available             cord-cephfs              7m
```

At this point you can create a `PersistentVolumeClaim` on `cord-ceph-rbd` and a
corresponding `PersistentVolume` will be created by the `rook-ceph-operator`
acting as a volume provisioner and bound to the PVC.

Creating a `PeristentVolumeClaim` on `cord-cephfs` will mount the same CephFS
filesystem on every container that requests it. The CephFS PV implementation
currently isn't as mature as the Ceph RDB volumes, and may not remount properly
when used with a PVC.

### Troubleshooting Rook

Checking the `rook-ceph-operator` logs can be enlightening:

```shell
kubectl -n rook-ceph-system logs -f rook-ceph-operator-...
```

The [Rook toolbox container](https://rook.io/docs/rook/v0.8/toolbox.html) has
been containerized as the `rook-tools` chart, and provides a variety of tools
for debugging Rook and Ceph.

Load the `rook-tools` chart:

```shell
helm install -n rook-tools rook-tools
```

Once the container is running (check with `kubectl -n rook-ceph get pods`),
exec into it to run a shell to access all tools:

```shell
kubectl -n rook-ceph exec -it rook-ceph-tools bash
```

or run a one-off command:

```shell
kubectl -n rook-ceph exec rook-ceph-tools -- ceph status
```

or mount the CephFS volume:

```shell
kubectl -n rook-ceph exec -it rook-ceph-tools bash
mkdir /mnt/cephfs
mon_endpoints=$(grep mon_host /etc/ceph/ceph.conf | awk '{print $3}')
my_secret=$(grep key /etc/ceph/keyring | awk '{print $3}')
mount -t ceph -o name=admin,secret=$my_secret $mon_endpoints:/ /mnt/cephfs
ls /mnt/cephfs
```

### Cleaning up after Rook

The `rook-operator` chart will leave a few `DaemonSet` behind after it's
removed. Clean these up using these commands:

```shell
kubectl -n rook-ceph-system delete daemonset rook-ceph-agent
kubectl -n rook-ceph-system delete daemonset rook-discover
helm delete --purge rook-operator
```

If you have other charts that create `PersistentVolumeClaims`, you may need to
clean them up manually (for example, if you've changed the `StorageClass` they
use), list them with:

```shell
kubectl --all-namespaces get pvc
```

Files may be left behind in the Ceph storage directory and/or Rook
configuration that need to be deleted before starting `rook-*` charts. If
you've used the `automation-tools/kubespray-installer` scripts to set up a
environment named `test`, you can delete all these files with the following
commands:

```shell
cd cord/automation-tools/kubespray-installer
ansible -i inventories/test/inventory.cfg -b -m shell -a "rm -rf /var/lib/rook && rm -rf /mnt/ceph/*" all
```

The current upgrade process for Rook involves manual intervention and
inspection using the tools container.

## Using Persistent Storage

The general process for using persistent storage is to create a
[PersistentVolumeClaim](https://kubernetes.io/docs/concepts/storage/persistent-volumes/#persistentvolumeclaims)
on the appropriate
[StorageClass](https://kubernetes.io/docs/concepts/storage/storage-classes/)
for the workload you're trying to run.

### Example: XOS Database on a local directory

For development and testing, it may be useful to persist the XOS database

```shell
helm install -f examples/xos-db-local-dir.yaml -n xos-core xos-core
```

### Example: XOS Database on a Ceph RBD volume

The XOS Database (Postgres) wants a volume that persists if a node goes down or
is taken out of service, not shared with other containers running Postgres,
thus the Ceph RBD volume is a reasonable choice to use with it.

```shell
helm install -f examples/xos-db-ceph-rbd.yaml -n xos-core xos-core
```

### Example: Docker Registry on CephFS shared filesystem

The Docker Registry wants a filesystem that is the shared across all
containers, so it's a suitable workload for the `cephfs` shared filesystem.

There's an example values file available in `helm-charts/examples/registry-cephfs.yaml`

```shell
helm install -f examples/registry-cephfs.yaml -n docker-registry stable/docker-registry
```

