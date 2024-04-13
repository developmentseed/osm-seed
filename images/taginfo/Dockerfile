FROM ruby:3.0 as builder
ARG workdir=/usr/src/app
WORKDIR $workdir
RUN apt-get update && apt-get install -y \
    cmake \
    libbz2-dev \
    libexpat1-dev \
    libgd-dev \
    libicu-dev \
    libosmium2-dev \
    libprotozero-dev \
    libsqlite3-dev \
    make \
    zlib1g-dev \
    curl \
    sqlite3 \
    sqlite3-pcre \
    passenger \
    libapache2-mod-passenger \
    libreadline-dev \
    tcl \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Clone and setup taginfo-tools
RUN git clone https://github.com/taginfo/taginfo-tools.git $workdir/taginfo-tools && \
    cd $workdir/taginfo-tools && \
    git submodule update --init && \
    mkdir build && cd build && \
    cmake .. && make

RUN apt-get update && apt-get install -y \
    passenger \
    libapache2-mod-passenger \
    git \
    jq \
    python3-pip \
    wget \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

RUN gem install json rack-contrib puma
RUN gem install sinatra -v '< 3'
RUN gem install sinatra-r18n -v '5.0.2'

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip

# Clone and setup taginfo
RUN git clone https://github.com/taginfo/taginfo.git $workdir/taginfo && \
    cd $workdir/taginfo && \
    bundle install

COPY config/taginfo-config.json $workdir/
COPY overwrite_config.py .
COPY start.sh .
