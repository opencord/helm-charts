# Nem Monitoring

To deploy this chart please use:

```shell
helm install -n nem-monitoring nem-monitoring/
```

It will expose:

- grafana on port `31300`
- prometheus on port `31301`

## Running on minikube

On minikube you don't need all the permission schema, so install this chart with:

```shell
helm install -n nem-monitoring nem-monitoring/ -f nem-monitoring/examples/nem-monitoring-minikube.yaml
```