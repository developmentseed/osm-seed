#!/usr/bin/env bash
for i in {1..10}
do
  docker run --env-file ./../.env --network osm-seed_default -t openseed-replication-job:v1
  sleep 120s
done