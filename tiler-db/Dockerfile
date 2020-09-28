FROM mdillon/postgis:9.5
RUN apt-get update
RUN apt-get install -y git ca-certificates

RUN git clone https://github.com/Open-Historical-Map-Labs/DateFunctions-plpgsql.git date-functions
RUN ls

COPY ./config/docker-entrypoint.sh /usr/local/bin/
RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./config/initdb_db.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./config/update_db.sh /usr/local/bin
RUN cp /date-functions/datefunctions.sql /docker-entrypoint-initdb.d/datefunctions.sql
