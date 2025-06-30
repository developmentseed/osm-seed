FROM debian:bookworm-slim
ENV workdir /mnt/data
WORKDIR $workdir

# Installs osmosis v0.48.3, osmium-tool v1.15.0, and PostgreSQL client
RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install \
    -y --no-install-recommends \
        osmosis \
        osmium-tool \
        # Cloud provider CLIs
        awscli \
        gsutil \
        azure-cli \
        # PostgreSQL client
        postgresql-client \
        # Other useful packages
        rsync \
        pyosmium \
        tmux \
        zsh  \
        git \
    && rm -rf /var/lib/apt/lists/*

# Install planet-dump-ng
RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
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
    && git clone -b timestamp_epoch https://github.com/OpenHistoricalMap/planet-dump-ng.git /opt/planet-dump-ng \
    && cd /opt/planet-dump-ng \
    && ./autogen.sh \
    && ./configure \
    && make \
    && ln -s /opt/planet-dump-ng/planet-dump-ng /usr/local/bin/planet-dump-ng \
    && rm -rf /var/lib/apt/lists/*
    