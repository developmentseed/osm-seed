FROM mdillon/postgis:9.5
RUN apt-get update
RUN apt-get install -y git ca-certificates

COPY ./config/docker-entrypoint.sh /usr/local/bin/
RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./config/initdb_db.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./config/update_db.sh /usr/local/bin

