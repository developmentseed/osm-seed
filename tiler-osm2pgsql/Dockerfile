FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y \
        make \
        cmake \
        g++ \
        git-core \
        libboost-dev \
        libboost-system-dev \
        libboost-filesystem-dev \
        libexpat1-dev \
        zlib1g-dev \
        libbz2-dev \
        libpq-dev \
        libgeos-dev \
        libgeos++-dev \
        libproj-dev \
        lua5.2 \
        liblua5.2-dev

ENV OSM2PGSQL_VERSION=0.96.0
ENV OSMCTOOLS_VERSION=0.8-1

# osm2pgsql
RUN cd /tmp && git clone --depth 1 --branch $OSM2PGSQL_VERSION https://github.com/openstreetmap/osm2pgsql.git && \
    mkdir -p osm2pgsql/build && \
    cd osm2pgsql/build  && \
    cmake .. && make install

# osmctools && clean up
RUN apt-get install -y osmctools postgresql-client \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# osm replication script
WORKDIR /osm
COPY start.sh start.sh
CMD ./start.sh
