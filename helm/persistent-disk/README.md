# Creating a SSD persistent disks for osm-seed

- storageClass

`kubectl apply -f db-storageclass.yaml`

- Persistent volume claim

`kubectl apply -f db-claim.yaml`


Once you created the storage class you could set the name  `osm-seed-storage-claim` on values.yaml



- Createating a externat disk 

`gcloud compute disks create --size=100GB --zone=us-west1-b --type=pd-standard osm-seed-data-disk`

`gcloud compute instances list`



- mount the disk

gcloud compute instances attach-disk gke-osm-seed-cluster-default-pool-9af789a5-1b33 --disk pg-data-disk

- Login ssh in the instance and format the disk
sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard /dev/sdc
sudo mkdir -p /mnt/disks/pg-data/
sudo mount -o discard,defaults /dev/sdc /mnt/disks/pg-data/
sudo umount /mnt/disks/pg-data


- Unmount  the disk

`gcloud compute instances detach-disk gke-osm-seed-cluster-default-pool-9af789a5-1b33 --disk pg-data-disk`


- Create the volume

`kubectl create -f postgres-persistence.yml`


- claim the volume

`kubectl create -f postgres-claim.yml`

https://stackoverflow.com/questions/30881637/postgres-with-kubernetes-and-persistentdisk?utm_medium=organic&utm_source=google_rich_qa&utm_campaign=google_rich_qa