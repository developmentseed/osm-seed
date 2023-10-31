FROM mdillon/postgis:9.5
RUN rm /etc/apt/sources.list.d/pgdg.list
RUN sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list
RUN sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list 
RUN sed -i '/stretch-updates/d' /etc/apt/sources.list 
RUN apt-get update && apt-get -y install apt-transport-https
RUN echo "deb https://apt-archive.postgresql.org/pub/repos/apt/ stretch-pgdg main 9.5" /etc/apt/sources.list.d/pgdg.list
RUN apt-get update && apt-get install -y git ca-certificates
COPY ./config/docker-entrypoint.sh /usr/local/bin/
RUN mkdir -p /docker-entrypoint-initdb.d
COPY ./config/initdb_db.sh /docker-entrypoint-initdb.d/postgis.sh
COPY ./config/update_db.sh /usr/local/bin
COPY ./config/update_postgresql.sh /docker-entrypoint-initdb.d
