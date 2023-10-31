FROM postgres:11
RUN rm /etc/apt/sources.list.d/pgdg.list
RUN sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list
RUN sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list 
RUN sed -i '/stretch-updates/d' /etc/apt/sources.list 
RUN apt-get update && apt-get -y install apt-transport-https
RUN echo "deb [ signed-by=/usr/local/share/keyrings/postgres.gpg.asc ] https://apt-archive.postgresql.org/pub/repos/apt/ stretch-pgdg main 11" >/etc/apt/sources.list.d/pgdg.list
RUN apt-get update \
    && apt-get install -y \
    postgresql-server-dev-11 \
    make \
    build-essential \
    postgresql-11-postgis-2.5 \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
    
ADD functions/functions.sql /usr/local/share/osm-db-functions.sql
ADD docker_postgres.sh /docker-entrypoint-initdb.d/
RUN mkdir -p db
RUN mkdir -p lib
ADD functions/ db/functions/
ADD lib/quad_tile/ lib/quad_tile/

RUN make -C db/functions/
RUN chown -R postgres lib/
RUN chown -R postgres db/
