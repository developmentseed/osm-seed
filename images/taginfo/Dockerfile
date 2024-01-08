FROM ruby:3.0
WORKDIR /apps
# Update and install dependencies in a single layer to reduce image size
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
    && rm -rf /var/lib/apt/lists/*
# Clone and set up Taginfo tools
RUN git clone https://github.com/taginfo/taginfo-tools.git taginfo-tools \
    && cd taginfo-tools \
    && git submodule update --init \
    && mkdir build \
    && cd build \
    && cmake .. \
    && make

# Clone and set up Taginfo
RUN git clone https://github.com/taginfo/taginfo.git taginfo \
    && cd taginfo \
    && echo "gem 'thin'" >> Gemfile \
    && gem install bundler \
    && bundle install

COPY overwrite_config.py start.sh ./
CMD ["./start.sh"]
