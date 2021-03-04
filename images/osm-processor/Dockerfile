FROM ubuntu:16.04
ENV workdir /mnt/data
RUN apt-get -y update && apt-get -y install \
    build-essential \
    libboost-program-options-dev \
    libbz2-dev \
    zlib1g-dev \
    libexpat1-dev \
    cmake \
    pandoc \
    git \
    python-pip \
    curl \
    unzip \
    wget \
    software-properties-common \
    python-software-properties \
    libz-dev \
    zlib1g-dev \
    gdal-bin \
    tar \
    bzip2 \
    clang \
    default-jre \
    default-jdk \
    gradle \
    apt-utils

# Install osmosis
RUN git clone https://github.com/openstreetmap/osmosis.git
WORKDIR osmosis
RUN git checkout 9cfb8a06d9bcc948f34a6c8df31d878903d529fc
RUN mkdir "$PWD"/dist
RUN ./gradlew assemble
RUN tar -xvzf "$PWD"/package/build/distribution/*.tgz -C "$PWD"/dist/
RUN ln -s "$PWD"/dist/bin/osmosis /usr/bin/osmosis
RUN osmosis --version 2>&1 | grep "Osmosis Version"

# Install osmium-tool
RUN git clone https://github.com/mapbox/protozero
RUN cd protozero && git checkout 23d48fd2a441c6e3b2852ff84a0ba398e48f74be && mkdir build && cd build && cmake .. && make && make install
RUN git clone https://github.com/osmcode/libosmium
RUN cd libosmium && git checkout a1f88fe44b01863a1ac84efccff54b98bb2dc886 && mkdir build && cd build && cmake .. && make && make install
RUN git clone https://github.com/osmcode/osmium-tool
RUN cd osmium-tool && git checkout ddbcb44f3ec0c1a8d729e69e3cee40d25f5a00b4 && mkdir build && cd build && cmake .. && make && make install

# Install AWS and GCP cli
RUN pip install awscli
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN ln -f -s /root/google-cloud-sdk/bin/gsutil /usr/bin/gsutil

# Install postgresql-client
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list'
RUN apt-get update
RUN apt-get install -y postgresql-client

WORKDIR $workdir
