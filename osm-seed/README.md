### Use Published Helm Chart

The recommended way to install osm-seed is to use the published Helm chart, rather than forking this repository. You can see a minimal example and basic instructions to do this at: https://github.com/developmentseed/osm-seed-deploy

The below instructions are still useful reading if you are using Helm and Kubernetes for the first time, and can still be used to develop locally. For any real-world installs, we now highly recommend using the public Helm Chart to make it easier to manage custom changes, etc.

## Helm Chart configuration

The `osm-seed` folder contains the `Helm` Chart to easily deploy osm-seed to a Kubernetes cluster. For more about helm, see https://helm.sh

### Requirements

  - `kubectl`: https://kubernetes.io/docs/tasks/tools/install-kubectl/
  - `helm`: https://docs.helm.sh/using_helm/#installing-helm

To test with a local Kubernetes cluster, you may also want to install `Minikube`: https://kubernetes.io/docs/tasks/tools/install-minikube/


### Setup your cluster

Follow instructions to setup a Kubernetes cluster on your favourite cloud / hosting provider: https://kubernetes.io/docs/setup/

If you want to test locally, you can simply run `minikube start --cpus 4 --memory 8192` to start your locally running cluster. 


### Setup `helm` on your cluster

You need to install `helm` onto your cluster, and make sure it has adequate permissions to install and upgrade Charts.

With `minikube` as your cluster backend, this can be accomplished with `helm init`. Depending on your Kubernetes cluster backend, you may need some extra steps to ensure `helm` has adequate permissions on your cluster. See https://github.com/kubernetes/helm/blob/master/docs/rbac.md

### Install dependencies on your cluster

To handle domain routing and SSL, osm-seed needs the nginx ingress controller setup on the cluster as well as Lets Encrypt to handle SSL certificate generation.

You can do this with:

```sh
    helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx --create-namespace
```

or install using `kubectl`

```sh
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.1.1/deploy/static/provider/cloud/deploy.yaml
```

For more options and cloud-specific instructions, see: https://kubernetes.github.io/ingress-nginx/deploy/

To install the Lets Encrypt `cert-manager` helm chart:

```sh
    helm repo add jetstack https://charts.jetstack.io
    helm repo update
    helm install \
        cert-manager jetstack/cert-manager \
        --namespace cert-manager \
        --create-namespace \
        --version v1.7.1 \
        --set installCRDs=true
```
For further information: https://cert-manager.io/docs/installation/helm/

### Install osm-seed onto your cluster

Look at the [`values.yaml`](values.yaml) file in the `osm-seed` sub-folder to see the various configuration options and values that you need to configure for your installation. Then create a `myvalues.yaml` file, where you can over-ride any of the values defined in `values.yaml`.

You can then install `osm-seed` with:

    helm install -f myvalues.yaml osm-seed/

This will setup all the resources required and give you instructions to get the URL of your running instance. You can also use the standard `kubectl` commands to monitor your cluster, view the cluster dashboard, etc.

This will output a generated name for the deployed `release`.

To delete all resources created in the Helm chart:

    helm delete <release-name> 


## Install osm-seed on minikube cluster

```sh
minikube delete --all
minikube start --mount-string=$PWD/data/:/mnt/ --mount --driver=docker
minikube ssh
chartpress
# It is necesary to create the folder in the shared folder 
mkdir -p $PWD/data/db-data
mkdir -p $PWD/data/tiler-db-data
mkdir -p $PWD/data/tiler-imposm-data
mkdir -p $PWD/data/tiler-server-data
mkdir -p $PWD/data/overpass-api-db-data
mkdir -p $PWD/data/nominatim-db-data

# Install develop version
helm install develop osm-seed -f osm-seed/values.yaml

# Expose web contianer service
minikube service develop-osm-seed-web --url

# Update develop version
helm upgrade develop osm-seed -f osm-seed/values.yaml

# Delete develop version
helm delete develop

```

### Additional Notes

When developing and testing locally, it is often useful to use the same `docker` context inside your minikube instance as your local machine. This avoids having to re-pull docker images from within your `minikube` VM. This can be accomplished with:

    eval $(minikube docker-env)

Some useful `kubectl` commands:

To get the status of all resources:

    kubectl get all

To get logs from a running container:

    kubectl logs <pod-id>

Refer the `kubectl` [documentation](https://kubernetes.io/docs/reference/kubectl/overview/)
