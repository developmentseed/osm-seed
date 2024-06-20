FROM ubuntu:24.04 AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
    apt-get install -y gcc g++ make cmake \
    libfcgi-dev libxml2-dev libmemcached-dev libbrotli-dev \
    libboost-program-options-dev libcrypto++-dev libyajl-dev \
    libpqxx-dev zlib1g-dev libfmt-dev git \
    ca-certificates \
    postgresql-16 postgresql-server-dev-all \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*


    RUN apt-get update -qq && \
    apt-get install -y wget

    # Install Argon2 from source
RUN wget https://github.com/P-H-C/phc-winner-argon2/archive/refs/tags/20190702.tar.gz && \
tar -xzf 20190702.tar.gz && \
cd phc-winner-argon2-20190702 && \
make && \
make install

WORKDIR /app

# Copy the main application.

ENV CGIMAP_GITSHA=26cd7fa10affe5dbd13dbe16de34421059f53f18
RUN git clone https://github.com/zerebubuth/openstreetmap-cgimap.git /app
RUN git checkout $CGIMAP_GITSHA


# Compile, install and remove source
RUN mkdir build && cd build && \
    CXXFLAGS="-Wall -Wextra -Wpedantic -Wno-unused-parameter" cmake .. -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=ON -DCMAKE_BUILD_TYPE=Release && \
    make -j${nproc} && \
    ctest --output-on-failure && \
    strip openstreetmap-cgimap && \
    cp openstreetmap-cgimap ../

FROM ubuntu:24.04

RUN apt-get update -qq && \
    apt-get install -y \
    libfcgi-bin libmemcached11 libboost-program-options1.83.0 \
    libxml2 libcrypto++8 libyajl2 libpqxx-7.8t64 zlib1g libbrotli1 libfmt9 \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /app/openstreetmap-cgimap /usr/local/bin

RUN groupadd -g 61000 cgimap && \
    useradd -g 61000 -l -M -s /bin/false -u 61000 cgimap

USER cgimap

COPY start.sh  /

EXPOSE 8000

# ENTRYPOINT 
CMD [ "/start.sh" ]