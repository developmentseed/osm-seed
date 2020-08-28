#!/bin/bash

workDir=/mnt/data
expire_dir=$workDir/imposm/imposm3_expire_dir
mkdir -p $expire_dir
echo "Starting Watcher...."
sum="not a sum"
while true ; do
  new_sum=`ls $IMPOSM3_EXPIRE | md5sum`
  if [ "$sum" != "$new_sum" ]; then
    ./seed-by-diffs.sh
  else
    sleep 1
  fi
done