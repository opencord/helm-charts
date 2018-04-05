To use xossh, execute the following from your `helm-charts` directory:

```
helm install xos-tools/xossh -n xossh
XOSSH_POD=`kubectl get pods | grep -i xossh | cut -f 1 -d " "`
kubectl attach $XOSSH_POD -i -c xossh
```
