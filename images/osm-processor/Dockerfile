# Stage 1: builder
FROM debian:bookworm-slim AS builder
WORKDIR /opt/planet-dump-ng

RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        build-essential \
        automake \
        autoconf \
        libxml2-dev \
        libboost-dev \
        libboost-program-options-dev \
        libboost-date-time-dev \
        libboost-filesystem-dev \
        libboost-thread-dev \
        libboost-iostreams-dev \
        libosmpbf-dev \
        osmpbf-bin \
        libprotobuf-dev \
        pkg-config \
        git \
    && git clone -b planet_epoch_date https://github.com/OpenHistoricalMap/planet-dump-ng.git . \
    && ./autogen.sh \
    && ./configure \
    && make \
    && strip planet-dump-ng

# Stage 2: slim runtime — planet-dump-ng + cloud CLIs + bzip2
FROM debian:bookworm-slim
ENV workdir=/mnt/data
WORKDIR $workdir

RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
    && install -d /usr/share/keyrings \
    && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc \
        | gpg --dearmor -o /usr/share/keyrings/pgdg.gpg \
    && echo "deb [signed-by=/usr/share/keyrings/pgdg.gpg] https://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" \
        > /etc/apt/sources.list.d/pgdg.list \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        bzip2 \
        awscli \
        gsutil \
        azure-cli \
        postgresql-client-17 \
        osmium-tool \
        python3-pyosmium \
        libxml2 \
        libboost-filesystem1.74.0 \
        libboost-program-options1.74.0 \
        libboost-thread1.74.0 \
        libboost-iostreams1.74.0 \
        libboost-date-time1.74.0 \
        libprotobuf32 \
        libprotobuf-lite32 \
        libosmpbf1 \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /opt/planet-dump-ng/planet-dump-ng /usr/local/bin/planet-dump-ng
