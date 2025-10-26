# Main test --> question 6

We can use Multus CNI to allow pods to connect to a secondary network interface without requiring a load balancer

## We can use below steps to implement and attach to pods as secondary CNI


1. Install Multus deamonset
```
kubectl apply -f https://raw.githubusercontent.com/k8snetworkplumbingwg/multus-cni/master/deployments/multus-daemonset.yml
```

2. Define network attachment
```
apiVersion: k8s.cni.cncf.io/v1
kind: NetworkAttachmentDefinition
metadata:
  name: secondary-net
  namespace: default
spec:
  config: '{
    "cniVersion": "0.3.1",
    "type": "aws-cni",
    "subnet": "subnet-xxxxxx",
    "routes": [{"dst": "0.0.0.0/0"}]
  }
```

3. Attach network interface to pod
```
apiVersion: v1
kind: Pod
metadata:
  name: mypod
  annotations:
    k8s.v1.cni.cncf.io/networks: secondary-net
spec:
  containers:
  - name: app
    image: myapp:latest

```