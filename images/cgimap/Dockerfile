FROM ruby:3.3.0 AS builder

ENV DEBIAN_FRONTEND=noninteractive
ENV workdir=/var/www
ENV CGIMAP_GITSHA=8ea707e10aeab5698e6859856111816d75354592
ENV cgimap=/tmp/openstreetmap-cgimap

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential cmake git curl file \
    libxml2-dev libpqxx-dev libfcgi-dev zlib1g-dev libbrotli-dev \
    libboost-program-options-dev libfmt-dev libmemcached-dev libcrypto++-dev \
    libargon2-dev libyajl-dev \
 && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/zerebubuth/openstreetmap-cgimap.git $cgimap \
 && cd $cgimap \
 && git checkout $CGIMAP_GITSHA \
 && mkdir build && cd build && cmake .. && cmake --build .


FROM ruby:3.3.0-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends curl gnupg && \
    echo "deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list && \
    curl -sSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get install -y --no-install-recommends \
    libxml2 libpqxx-6.4 libfcgi zlib1g libbrotli1 \
    libboost-program-options1.74.0 libfmt-dev libmemcached11 libcrypto++8 \
    libargon2-1 libyajl2 libapache2-mod-fcgid postgresql-client \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/*

COPY --from=builder /tmp/openstreetmap-cgimap/build/openstreetmap-cgimap /usr/local/bin/openstreetmap-cgimap

COPY *.sh /
RUN chmod +x /*.sh && echo "/usr/local/lib" > /etc/ld.so.conf.d/local_libs.conf && ldconfig

CMD ["/start.sh"]
