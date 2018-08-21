FROM ubuntu:14.04
ENV GOPATH /usr/bin
RUN apt-get -y update
RUN apt-get install -y \
        build-essential \
        make \
        cmake \
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
        libjson0-dev

RUN apt-get install -y python-software-properties \
        python3-software-properties \
        software-properties-common \
        wget

RUN add-apt-repository ppa:gophers/archive
RUN apt-get -y update
RUN apt-get install -y golang-1.10-go
RUN cp /usr/lib/go-1.10/bin/go /usr/bin/go
RUN cp /usr/lib/go-1.10/bin/gofmt /usr/bin/gofmt

# RUN wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
# RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
# RUN apt-get -y update
RUN apt-get install -y postgresql postgresql-contrib




RUN mkdir -p go
WORKDIR /go
RUN export GOPATH=`pwd`
RUN go get github.com/omniscale/imposm3
RUN go install github.com/omniscale/imposm3/cmd/imposm
RUN cp $GOPATH/bin/imposm /usr/bin/imposm

WORKDIR /osm
COPY ./config/imposm3.json imposm3.json
COPY ./config/postgis_helpers.sql postgis_helpers.sql
COPY ./config/postgis_index.sql postgis_index.sql
COPY start.sh start.sh
COPY scripts scripts
CMD ./start.sh
