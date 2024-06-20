FROM osgeo/gdal:ubuntu-small-3.2.3

RUN apt-get -y update
RUN apt-get install -y \
    g++ \
    libboost-dev \
    libboost-system-dev \
    libboost-filesystem-dev \
    libexpat1-dev \
    zlib1g-dev \
    libbz2-dev \
    libpq-dev \
    libgeos++-dev \
    libproj-dev \
    libleveldb-dev \
    libgeos-dev \
    libprotobuf-dev \
    git-core \
    curl \
    wget \
    unzip \
    software-properties-common && \
    rm -rf /var/lib/apt/lists/*

# Install Python 3.6
RUN apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:ubuntu-toolchain-r/test && \
    apt-get update && \
    apt-get install -y gcc-8 g++-8 && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 100 && \
    update-alternatives --install /usr/bin/g++ g++ /usr/bin/g++-8 100 && \
    apt-get install -y build-essential wget libssl-dev zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev && \
    wget https://www.python.org/ftp/python/3.6.15/Python-3.6.15.tgz && \
    tar xzf Python-3.6.15.tgz && \
    cd Python-3.6.15 && \
    ./configure --enable-optimizations && \
    make altinstall && \
    cd .. && \
    rm -rf Python-3.6.15 Python-3.6.15.tgz && \
    apt-get install -y python3-pip && \
    python3.6 -m pip install pip --upgrade && \
    python3.6 -m pip install wheel && \
    rm -rf /var/lib/apt/lists/*

# Install postgresql-client
RUN apt-get update && apt-get install -y postgresql-client && \
    rm -rf /var/lib/apt/lists/*

# Install go
RUN wget -c https://dl.google.com/go/go1.10.linux-amd64.tar.gz -O - | tar -xz -C /usr/local
ENV PATH $PATH:/usr/local/go/bin

WORKDIR /go
ENV GOPATH /go
RUN go get github.com/omniscale/imposm3
WORKDIR $GOPATH/src/github.com/omniscale/imposm3
RUN git checkout v0.11.1
RUN go install github.com/omniscale/imposm3/cmd/imposm
ENV PATH $PATH:$GOPATH/bin

# Install awscli  and gsutil  to get the pbf file
RUN pip3 install -U setuptools
RUN pip3 install awscli
RUN pip3 install gsutil

ENV IMPOSMDATA /mnt/data
RUN mkdir -p $IMPOSMDATA && chmod 777 -R $IMPOSMDATA
WORKDIR $IMPOSMDATA
VOLUME $IMPOSMDATA

WORKDIR /osm
COPY . .
CMD ./start.sh