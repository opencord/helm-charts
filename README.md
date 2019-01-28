# Helm charts for CORD

This repo contains the helm charts for use in the [CORD](https://opencord.org/)
and subsidiary projects.

Thes charts are published on: <https://charts.opencord.org/>

Please see <https://guide.opencord.org/charts/helm.html> for more complete
documentation.

## Changing charts

When you make changes to charts, please make sure of the following:

1. Make sure the chart passes a strict lint with `helm lint --strict
   <chartname>`.  The `scripts/helmlint.sh` will check all charts.

2. When you modify a chart, you must increase the version in `Chart.yaml`. You
   may also need to update other charts that depend on your chart.
