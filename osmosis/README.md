### Osmosis Container

Dockerfile definition to run a container with `osmosis` installed. This container definition will be responsible to run various tasks:

 - Import OSM data from a pbf file on s3 into the api database
 - Export data from the api database to a pbf and upload to s3

This container needs some environment variables passed into it in order to run:

 - `S3_OSM_PATH` - path on s3 to pbf file to import (if using `import_osm.sh`)
 - `AWS_ACCESS_KEY_ID` - your AWS access key
 - `AWS_SECRET_ACCESS_KEY` - AWS secret
 - `AWS_DEFAULT_REGION` - AWS region for s3 access

Note: the AWS credentials are not required if running this as a service with an IAM role defined to grant access to the relevant s3 paths.