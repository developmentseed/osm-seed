# Deploying osm-seed locally step by step

This is an alternative guide to make the deployment little by little, according to the resources that are being used!!

## Deploying Database and API pods.

Let's start by installing the Chart in the cluster, it could be locally or in the cloud, in this case, let's use a local minikube cluster.

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

let's check if the pods are running 👉 `kubectl get pods`

```
$ kubectl get pods
NAME                                READY     STATUS    RESTARTS   AGE
dev-db-0                            1/1       Running   0          1m
dev-osm-seed-web-74b7b58765-h9tqt   1/1       Running   0          1m
```

Let's check if our application is running correctly, we will execute 👉 `minikube service dev-osm-seed-web --url` to access the application.

```
$ minikube service dev-osm-seed-web --url
http://192.168.64.22:30483
```

For local deployment, we have to update the domain part in the values.yaml file, using the ip which we got.👉 `192.168.64.22:30483`


```yaml
domain:
  enabled: true 
  domainName: 192.168.64.22:30483
  protocolo: http
```

And then upgrade the stack: 👇

```
$ cd osm-seed/helm/
$ helm upgrade -f osm-seed/dev.values.yaml dev osm-seed/
```

*Note: The osm application could take couple of minutes to start up.* 

Open the ip `http://192.168.64.22:30483`, and verify that the osm application is working. Everything is going fine so far 😃!!!

## Deploying popupate-apidb pod

In order to deploy this container, we can use `kubectl`, or we can also add the file `populate-apidb-job.yaml` in the `templates` folder, the result would be 👇

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

And then upgrade the stack !! 👇

```
$ cd osm-seed/helm/
$ helm upgrade -f osm-seed/dev.values.yaml dev osm-seed/
```

You will see a result like this 👇


```
NAME                               READY  STATUS             RESTARTS  AGE
dev-osm-seed-web-68dbd7768f-qlt8r  1/1    Running            0         17m
dev-db-0                           1/1    Running            0         34m
dev-populate-apidb-job-ftght       0/1    ContainerCreating  0         0s
```

To verify the status of the import execute command 

```
kubectl logs dev-populate-apidb-job-ftght
```

Result 👇

![image](https://user-images.githubusercontent.com/1152236/45645360-c72f9080-ba85-11e8-8129-abad8dc4e0bb.png)

Now you have the Monaco country imported into your local database. For verifying if the data is in the Database, we will export some data from Monaco from our instance.


```
wget -O map.osm http://192.168.64.22:30483/api/0.6/map?bbox=7.42529%2C43.7381%2C7.42855%2C43.73984s
```

## Deploying iD-editor pod

In order to deploy an iD-editor, we need create copy the files `id-editor-deployment.yaml` and  `id-editor-service.yaml` into the `templates` folder.

The reults would be 👇

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

And then upgrade the stack !! 👇

```
$ cd osm-seed/helm/
$ helm upgrade -f osm-seed/dev.values.yaml dev osm-seed/
```

Result 👇

```
NAME                                   READY  STATUS             RESTARTS  AGE
dev-osm-seed-id-editor-b96f79c8-f72kg  0/1    ContainerCreating  0         0s
dev-osm-seed-web-68dbd7768f-qlt8r      1/1    Running            0         48m
dev-db-0                               1/1    Running            0         1h
dev-populate-apidb-job-ftght           0/1    Completed          0         30m
```

In the case of minikube, the assignment of the ports are randomly, so we can check on which port is running the iD-editor.


```
$ minikube service dev-osm-seed-id-editor --url
http://192.168.64.22:31711
```









