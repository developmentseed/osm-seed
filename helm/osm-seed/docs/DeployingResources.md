# Deploying osm-seed locally step by step

This is an alternative guide to make the deployment little by little, according to the resources that are being used!!

## Deploying Database and API pods.

Let's start installing the chart in the cluster, it could be locally or in the cloud, in this case, let's use a local minikube cluster.

Let's keep the following files in `template` folder.

```
_helpers.tpl
db-pd.yaml
db-service.yaml
db-statefulset.yaml
ingress.yaml
web-deployment.yaml
web-service.yaml
```

Make sure you `value.yaml` configuration was filled, and then execute 👇

```
$ cd osm-seed/helm/
$ helm install -n dev -f osm-seed/dev.values.yaml osm-seed/
```

let's check if the pods are running 👇

```
$ kubectl get pods
NAME                                READY     STATUS    RESTARTS   AGE
dev-db-0                            1/1       Running   0          9m
dev-osm-seed-web-d9584cd86-hb7q8    1/1       Running   0          9m
```

Let's get the IP where our aplication is running 👇

```
$ minikube service dev-osm-seed-web --url
http://192.168.64.26:32331
```

For local deployment, we have to update the `domain` value in the values.yaml file, we are going to use the IP which we got 👇


```yaml
# values.yaml
domain:
  enabled: true 
  domainName: 192.168.64.26:32331
  protocolo: http
```

And then upgrade the stack 👇

```
$ cd osm-seed/helm/
$ helm upgrade -f osm-seed/dev.values.yaml dev osm-seed/
```

*Note: The osm application could take couple of minutes to start up.* 

Open the ip `http://192.168.64.26:32331`, and verify that the osm application is working. Everything is going fine so far 😃!!!

## Deploying popupate-apidb pod

In order to deploy this container, we can use `kubectl` [explaining here](RunIndependentlyPod.md) , or we can also add the file `populate-apidb-job.yaml` in the `templates` folder, we will choose the second option, make a copy of the file, result would be like this👇

```
_helpers.tpl
db-backup-job.yaml
db-pd.yaml
db-service.yaml
db-statefulset.yaml
ingress.yaml
populate-apidb-job.yaml
web-deployment.yaml
web-service.yaml
```

And then let's upgrade the chart 👇

```
$ cd osm-seed/helm/
$ helm upgrade -f osm-seed/dev.values.yaml dev osm-seed/
```

You will see a result like this 👇

```
$ kubectl get pods
NAME                                READY     STATUS      RESTARTS   AGE
dev-db-0                            1/1       Running     0          4m
dev-osm-seed-web-7687fd75db-f77gc   1/1       Running     0          49s
dev-populate-apidb-job-pg68l        0/1       Completed   0          4m
```

Check the logs using 👇

```
kubectl logs dev-populate-apidb-job-pg68l 
```

Now you have the Monaco country imported into your local database. For verifying if the data is in the Database, we will export some data from Monaco from our instance.


```
wget -O map.osm http://192.168.64.26:32331/api/0.6/map?bbox=7.42529%2C43.7381%2C7.42855%2C43.73984s
```

## Deploying iD-editor pod

In order to deploy an iD-editor, we need create copy the files `id-editor-deployment.yaml` and  `id-editor-service.yaml` into the `templates` folder.

The reults would be like this 👇

```
_helpers.tpl
db-backup-job.yaml
db-pd.yaml
db-service.yaml
db-statefulset.yaml
id-editor-deployment.yaml
id-editor-service.yaml
ingress.yaml
populate-apidb-job.yaml
web-deployment.yaml
web-service.yaml
```

Before the update the chart, we need to register a client application, to do that use the OSM-API Domain or IP. 👇.

![image](https://user-images.githubusercontent.com/1152236/45662126-31682580-bac6-11e8-8612-391c3a769d7d.png)

And then updateh the `values.yaml` file

```yaml
idEditor:
  image: 'developmentseed/osmseed-id-editor'
  replicaCount: 1
  serviceType: NodePort
  staticIp:
    enabled : false
  env:
    OSM_API_PROTOCOL: http
    OSM_API_DOMAIN: 192.168.64.26:32331 # osm-api domain or IP
    OAUTH_CONSUMER_KEY : gqQruapvmE5prKUiP2zXXFmdzsE9preyka3NOm6K
    OAUTH_SECRET : uBag7fQbBDVOSjlFllViqjPYriYyUCNcFnKparZZ
```

And then upgrade the chart !! 👇

```
$ cd osm-seed/helm/
$ helm upgrade -f osm-seed/dev.values.yaml dev osm-seed/
```

Result 👇

```
NAME                                      READY     STATUS              RESTARTS   AGE
dev-db-0                                  1/1       Running             0          9m
dev-osm-seed-id-editor-785b89c7bd-hj5j5   0/1       ContainerCreating   0          7s
dev-osm-seed-web-7687fd75db-f77gc         1/1       Running             0          6m
dev-populate-apidb-job-pg68l              0/1       Completed           0          9m
```

Get the IP of the iD-editor 👇

```
$  minikube service dev-osm-seed-id-editor --url
http://192.168.64.26:30416
```