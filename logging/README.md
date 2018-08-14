# Logging

This chart implements a log aggregation framework built on elasticsearch within
kubernetes.

It requires persistent storage, and currently has default values for the
`local-provisioner` with storage on each k8s node.

Once these prereqs are satisfied, it can be run with:

    helm install -n logging logging

(NOTE: the name must be `logging` currently, or name lookups within the pod are broken)

## Current log sources

- Container logs from k8s with [fluentd-elasticsearch](https://github.com/helm/charts/tree/master/stable/fluentd-elasticsearch)

## Using Kibana

Visit: http://<k8s_node_hostname>:30601

