## Helm Chart configuration

The `osm-seed` folder contains the `Helm` Chart to easily deploy osm-seed to a Kubernetes cluster. For more about helm, see https://helm.sh

### Setting up

Requirements:

  - `minikube`: https://kubernetes.io/docs/tasks/tools/install-minikube/
  - `kubectl`: https://kubernetes.io/docs/tasks/tools/install-kubectl/
  - `helm`: https://docs.helm.sh/using_helm/#installing-helm

Start minikube and your local Kubernetes cluster:

```
    minukube start
```

Check `minikube` status:

```
    minikube status
```

Initialize `helm` on the cluster:

```
    helm init
```

Install the app onto the cluster:

```
    helm install -n <name> osm-seed/
```

Refer to `osm-seed/Values.yaml` for configuration values that can be over-ridden, and `helm` docs on methods to over-ride.

To see status of deployments:

```
    kubectl get deployments
```

To get logs from the container:

```
    kubectl get pods
```

Then:

```
    kubectl logs <pod_id>
```

To get the URL you can visit in your browser to see the site:

```
    minikube service web --url
```

This will output a URL you should be able to open in your browser.

Refer to `kubectl` documentation for more information on interacting with the cluster.

To delete all the resources created above:

```
    helm delete <name>
```

### Using Minkube Docker context

To avoid your Kubernetes cluster having to re-pull Docker images that you build on your host, you can change your docker context to store its image cache inside the `minikube` VM. You can do:

```
    eval $(minikube docker-env)
```

You will need to make sure you build the images with the same name + tag combination that you use as image definitions inside the `deployment` YAML files.

### Coming Soon

Instructions on deploying to AWS.
