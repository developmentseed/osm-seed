## Helm Chart configuration

The `osm-seed` folder contains the `Helm` Chart to easily deploy osm-seed to a Kubernetes cluster. For more about helm, see https://helm.sh

### Setting up

Requirements:

  - `minikube`: https://kubernetes.io/docs/tasks/tools/install-minikube/
  - `kubectl`: https://kubernetes.io/docs/tasks/tools/install-kubectl/
  - `helm`: https://docs.helm.sh/using_helm/#installing-helm


### [Deploying osm-seed in local Kubernetes cluster](ttps://github.com/developmentseed/osm-seed/blob/master/helm/localCluster.md)


### Deploying osm-seed in production Kubernetes cluster

- Creating a Google Disk

`gcloud compute disks create --size=100GB --zone=us-west1-b --type=pd-standard osm-seed-data-disk`

Note:

The disk and the cluster must be in the same availability zone.

Set the name of the disk in the `values.yaml` file.



