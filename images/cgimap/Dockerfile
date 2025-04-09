FROM debian:bullseye AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV CGIMAP_GITSHA=8ea707e10aeab5698e6859856111816d75354592

RUN apt-get update && apt-get install -y \
    build-essential cmake git \
    libxml2-dev libpqxx-dev libfcgi-dev zlib1g-dev libbrotli-dev \
    libboost-program-options-dev libfmt-dev libmemcached-dev libcrypto++-dev \
    libargon2-dev libyajl-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

RUN git clone -b master https://github.com/zerebubuth/openstreetmap-cgimap.git /cgimap \
    && cd /cgimap && git checkout $CGIMAP_GITSHA \
    && mkdir /cgimap/build && cd /cgimap/build \
    && cmake .. && cmake --build .

FROM debian:bullseye-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y \
    libxml2 libpqxx-6.4 libfcgi zlib1g libbrotli1 \
    libboost-program-options1.74.0 libfmt7 libmemcached11 libcrypto++8 \
    libargon2-1 libyajl2 && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

COPY --from=builder /cgimap/build/openstreetmap-cgimap /usr/local/bin/openstreetmap-cgimap

ENTRYPOINT ["/usr/local/bin/openstreetmap-cgimap"]
