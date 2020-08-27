# Running independently a pod or group of pods

OSM-seed is composed of many resources, which sometimes it will need to run only to a couple of them, a solution to execute only a couple of resources, it would be to remove the resources that are not needed from the folder /templates, and then execute `helm install`.

But another problem arises when we need to run a pod after that has already been executed `helm install`, So for this case we are going to use [helm-template](https://docs.helm.sh/helm/#helm-template).


```
cd helm/osm-seed/
helm template -f values.yaml -n osm-seed-staging . -x $(pwd)/templates/populate-apidb-job.yaml > populate-apidb-job-filled.yaml
```

Make sure the `-n` parameter is the name of your release.

Lastly create the pod using `kubectl` 👇

```
kubectl create -f populate-apidb-job-filled.yaml
```