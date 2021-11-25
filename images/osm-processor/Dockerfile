FROM ubuntu:20.04
ENV workdir /mnt/data

RUN apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install  \
    build-essential \
    libboost-program-options-dev \
    libbz2-dev \
    zlib1g-dev \
    libexpat1-dev \
    cmake \
    pandoc \
    git \
    python3 \
    python3-pip \
    curl \
    unzip \
    wget \
    software-properties-common \
    libz-dev \
    gdal-bin \
    tar \
    bzip2 \
    clang \
    default-jre \
    default-jdk \
    gradle \
    apt-utils \
    postgresql-client

# Install osmosis 0.48
RUN echo "osmosis"
RUN git clone https://github.com/openstreetmap/osmosis.git
WORKDIR osmosis
RUN git checkout bb0e592671a9bf0c48db1301cdc3d6085c88bae9
RUN mkdir "$PWD"/dist
RUN ./gradlew assemble
RUN tar -xvzf "$PWD"/package/build/distribution/*.tgz -C "$PWD"/dist/
RUN ln -s "$PWD"/dist/bin/osmosis /usr/bin/osmosis
RUN osmosis --version 2>&1 | grep "Osmosis Version"

# Install osmium-tool
RUN apt-get -y install \
    libbz2-dev \
    libgd-dev \
    libosmium2-dev \
    libprotozero-dev \
    libsqlite3-dev \
    make \
    jq \
    ca-certificates

# Other useful packages
RUN apt-get install -y \
    osmium-tool \
    pyosmium \
    rsync \
    tmux \
    zsh

RUN pip install osmium

# Install AWS and GCP cli
RUN pip install awscli
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN ln -f -s /root/google-cloud-sdk/bin/gsutil /usr/bin/gsutil

WORKDIR $workdir