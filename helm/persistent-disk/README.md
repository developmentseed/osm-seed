# Creating a SSD persistent disks for osm-seed

- storageClass

`kubectl apply -f db-storageclass.yaml`

- Persistent volume claim

`kubectl apply -f db-claim.yaml`


Once oyu created the storage class you could set the name  `osm-seed-storage-claim` on values.yaml
