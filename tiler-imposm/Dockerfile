FROM ubuntu:16.04

RUN apt-get -y update
RUN apt-get install -y \
     \
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
    libleveldb-dev \
    libgeos-dev \
    libprotobuf-dev \
    libgeos++-dev \
    libjson0-dev \
    curl \
    wget \
    unzip \
    software-properties-common

# Install python
RUN add-apt-repository ppa:deadsnakes/ppa \
        && apt-get update && \
        apt-get update -y  && \
        apt-get install -y build-essential python3.6 python3.6-dev python3-pip && \
        apt-get install -y git  && \
        # update pip
        python3.6 -m pip install pip --upgrade && \
        python3.6 -m pip install wheel

# Install postgresql-client
RUN wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main" | tee  /etc/apt/sources.list.d/pgdg.list' \
    && apt-get update && apt-get install -y postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Gdal is required to process the natural earth files
RUN add-apt-repository ppa:ubuntugis/ppa \
    && apt-get -y update \
    && apt-get install -y gdal-bin \
    && rm -rf /var/lib/apt/lists/*

# Install go
RUN add-apt-repository ppa:gophers/archive \
    && apt-get -y update \
    && apt-get install -y golang-1.10-go \
    && cp /usr/lib/go-1.10/bin/go /usr/bin/go \
    && cp /usr/lib/go-1.10/bin/gofmt /usr/bin/gofmt

# Install imposm
ENV GOPATH /usr/bin
RUN mkdir -p go
WORKDIR /go
RUN export GOPATH=`pwd`
RUN go get github.com/omniscale/imposm3
RUN go install github.com/omniscale/imposm3/cmd/imposm
RUN cp $GOPATH/bin/imposm /usr/bin/imposm

# Install awscli  and gsutil  to get the pbf file
RUN pip3 install -U setuptools
RUN pip3 install awscli
RUN pip3 install gsutil


ENV IMPOSMDATA /mnt/data
RUN mkdir -p "$IMPOSMDATA" && chmod 777 "$IMPOSMDATA"
VOLUME /mnt/data

WORKDIR /mnt/data
WORKDIR /osm
COPY config config
COPY scripts scripts
COPY start.sh start.sh
CMD ./start.sh