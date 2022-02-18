FROM postgres:11
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
