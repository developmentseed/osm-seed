#!/usr/bin/env bash
export PGPASSWORD=$POSTGRES_PASSWORD

date=`date '+%Y-%m-%d:%H:%M'`
backupfile=osm-seed-${date}.sql.gz
# Backup database and make maximum compression at the slowest speed
/usr/bin/pg_dump -h $POSTGRES_HOST -U $POSTGRES_USER $POSTGRES_DB  | gzip -9 > $backupfile

# Upload to S3
aws s3 cp $backupfile $S3_OSM_PATH/$backupfile
