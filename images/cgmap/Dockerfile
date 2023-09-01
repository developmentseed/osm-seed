FROM ubuntu:20.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
    apt-get install -y gcc g++ make autoconf automake libtool \
       libfcgi-dev libxml2-dev libmemcached-dev \
       libboost-program-options-dev \
       libcrypto++-dev libyajl-dev \
       libpqxx-dev zlib1g-dev libargon2-dev libfmt-dev \
       postgresql-12 postgresql-server-dev-all \
       git ca-certificates \
       --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

RUN git clone https://github.com/zerebubuth/openstreetmap-cgimap.git ./
RUN git checkout v0.8.8

# Compile, install and remove source
RUN ./autogen.sh && \
    ./configure --enable-static --disable-shared --enable-yajl && \
    make -j3 && \
    make check && \    
    strip openstreetmap-cgimap

FROM ubuntu:20.04

RUN apt-get update -qq && \
    apt-get install -y \
       libfcgi-bin libmemcached11 libboost-locale1.71.0 libboost-program-options1.71.0 \
       libxml2 libcrypto++6 libyajl2 libpqxx-6.4 zlib1g libargon2-1 \
       --no-install-recommends lighttpd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/openstreetmap-cgimap /usr/local/bin

RUN groupadd -g 61000 cgimap && \
    useradd -g 61000 -l -M -s /bin/false -u 61000 cgimap

USER cgimap
COPY start.sh /
COPY lighttpd.conf /
CMD /start.sh