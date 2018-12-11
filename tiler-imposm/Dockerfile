FROM ubuntu:14.04
ENV GOPATH /usr/bin
RUN apt-get -y update
RUN apt-get install -y \
    build-essential \
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
    postgresql \
    postgresql-contrib \
    python-pip \
    software-properties-common \
    python-software-properties 

# Install awscli  and gsutil  to get the pbf file
RUN pip install awscli
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN ln -f -s /root/google-cloud-sdk/bin/gsutil /usr/bin/gsutil

# Gdal is required to process the natural earth files
RUN add-apt-repository ppa:ubuntugis/ppa
RUN apt-get -y update
RUN apt-get install -y gdal-bin

# Install go
RUN add-apt-repository ppa:gophers/archive
RUN apt-get -y update
RUN apt-get install -y golang-1.10-go
RUN cp /usr/lib/go-1.10/bin/go /usr/bin/go
RUN cp /usr/lib/go-1.10/bin/gofmt /usr/bin/gofmt

# Install imposm
RUN mkdir -p go
WORKDIR /go
RUN export GOPATH=`pwd`
RUN go get github.com/omniscale/imposm3
RUN go install github.com/omniscale/imposm3/cmd/imposm
RUN cp $GOPATH/bin/imposm /usr/bin/imposm

ENV IMPOSMDATA /mnt/data
RUN mkdir -p "$IMPOSMDATA" && chmod 777 "$IMPOSMDATA"
VOLUME /mnt/data

WORKDIR /osm
COPY ./config/imposm3.json imposm3.json
COPY ./config/postgis_helpers.sql postgis_helpers.sql
COPY ./config/postgis_index.sql postgis_index.sql
COPY start.sh start.sh
COPY scripts scripts
CMD ./start.sh