# Accessing to Default Dashboard 

In order to acces to the kubectl dashboard you need to get the token:

```
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml
kubectl apply -f dashboard_cluster_role.yaml
kubectl -n kube-system get secret
```

find the a pod called: `replicaset-controller-token-*` and then run the next cli:

```
kubectl -n kube-system describe secret replicaset-controller-token-*
```

Copy the `token`, you will use that to login in the dashboard.


Execute the following cli:

```
kubectl proxy
```

Open: http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy

And then paste the `token` value in 👇  to login in the dashboard.


![](https://user-images.githubusercontent.com/2285385/29920994-5214087e-8e50-11e7-8ab9-c75755b62a47.png)


REF: https://github.com/kubernetes/dashboard/wiki/Access-control#getting-token-with-kubectl