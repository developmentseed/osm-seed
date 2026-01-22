FROM debian:bookworm-slim AS builder

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && \
    apt-get install -y gcc g++ make cmake \
    libfcgi-dev libxml2-dev libmemcached-dev libbrotli-dev \
    libboost-program-options-dev libcrypto++-dev libyajl-dev \
    libpqxx-dev zlib1g-dev libfmt-dev \
    postgresql-15 postgresql-server-dev-all dpkg-dev file ca-certificates git \
    --no-install-recommends && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app
    
# Clone application.
ENV CGIMAP_GITSHA=8ea707e10aeab5698e6859856111816d75354592
RUN git clone https://github.com/zerebubuth/openstreetmap-cgimap.git /app \
&& git checkout $CGIMAP_GITSHA \
&& sed -i 's#OpenStreetMap and contributors#osmseed is dedicated to the public domain except where otherwise noted.#g' include/cgimap/output_formatter.hpp \
&& sed -i 's#http://www.openstreetmap.org/copyright#https://github.com/osm-seed#g' include/cgimap/output_formatter.hpp
# Compile, install and remove source
RUN mkdir build && cd build && \
    CXXFLAGS="-flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2" \
    cmake .. -DCMAKE_INSTALL_PREFIX=/usr -DBUILD_SHARED_LIBS=OFF -DBUILD_TESTING=ON -DCMAKE_BUILD_TYPE=Release && \
    cmake --build . -j2 && \
    ctest --output-on-failure && \
    cmake --build . --target package

FROM debian:bookworm-slim

COPY --from=builder /app/build/*.deb /app_deb/

RUN apt-get update -qq && \
    apt install --no-install-recommends -y /app_deb/*.deb postgresql-client procps && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN groupadd -g 61000 cgimap && \
    useradd -g 61000 -l -M -s /bin/false -u 61000 cgimap

EXPOSE 8000

COPY ./*.sh .

CMD ["/start.sh"]