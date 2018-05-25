## Kubernetes Configuration

This folder contains necessary configuration files to deploy osm-seed on a Kubernetes cluster.

### Setting up

Requirements:

  - `minikube`: https://kubernetes.io/docs/tasks/tools/install-minikube/
  - `kubectl`: https://kubernetes.io/docs/tasks/tools/install-kubectl/

Start minikube and your local Kubernetes cluster:

```
    minukube start
```

Check `minikube` status:

```
    minikube status
```

Use `kubectl` to deploy `osm-seed`:

```
    kubectl create -f kube-yaml/
```

This will create the necessary services and deployments for the stack.

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
    kubectl delete -f kube-yaml/
```

### Using Minkube Docker context

To avoid your Kubernetes cluster having to re-pull Docker images that you build on your host, you can change your docker context to store its image cache inside the `minikube` VM. You can do:

```
    eval $(minikube docker-env)
```

You will need to make sure you build the images with the same name + tag combination that you use as image definitions inside the `deployment` YAML files.

### Coming Soon

Instructions on deploying to AWS.
