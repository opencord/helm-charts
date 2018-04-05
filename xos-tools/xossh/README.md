To use xossh, execute the following from your `helm-charts` directory:

```
# start the xossh container
helm install xos-tools/xossh -n xossh

# wait a few seconds for the container to start, then run the following
xos-tools/xossh/xossh-attach.sh
```
