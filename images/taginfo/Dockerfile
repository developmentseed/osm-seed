FROM ruby:2.4
ENV workdir /apps
WORKDIR $workdir
RUN apt-get update && apt-get install -y \
    curl \
    sqlite3 \
    sqlite3-pcre \
    ruby-passenger \
    libapache2-mod-passenger \
    git \
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
    jq \
    ca-certificates \
    osmium-tool \
    pyosmium \
    rsync \
    tmux \
    zsh \
    nano \
    vim \
    && rm -rf /var/lib/apt/lists/* # Clean up to reduce image size

# Clone and setup taginfo-tools
RUN git clone https://github.com/taginfo/taginfo-tools.git $workdir/taginfo-tools && \
    cd $workdir/taginfo-tools && \
    git submodule update --init && \
    mkdir build && cd build && \
    cmake .. && make

# Clone and setup taginfo
RUN git clone https://github.com/taginfo/taginfo.git $workdir/taginfo && \
    cd $workdir/taginfo && \
    git checkout ae5a950f7aa4c0de4e706839619a1dc05fc4450a && \
    echo "gem 'thin' " >> Gemfile && \
    gem install bundler -v 2.3.27 && \
    bundle install

COPY overwrite_config.py $workdir/
COPY start.sh $workdir/
CMD $workdir/start.sh
