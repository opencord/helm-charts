To use xossh, execute the following from your `helm-charts` directory:

```
# start the xossh container
helm install xos-tools/xossh -n xossh

# wait a few seconds for the container to start, then run the following
xos-tools/xossh/xossh-attach.sh
```

To deploy a development version of `xossh` tagged with the `candidate` tag, you can do:

```
helm install xos-tools/xossh/ -n xossh -f examples/xossh-candidate.yaml
```
