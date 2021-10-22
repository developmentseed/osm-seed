FROM ruby:2.7
ENV workdir /apps

# Install Taginfo site
RUN apt-get update && apt-get -y install \
    curl \
    sqlite3 \
    sqlite3-pcre \
    ruby-passenger \
    libapache2-mod-passenger \
    git

RUN git clone https://github.com/taginfo/taginfo.git $workdir/taginfo
WORKDIR $workdir/taginfo
RUN echo "gem 'thin' " >>Gemfile
RUN gem install bundler
RUN bundle install

# Install Taginfo tools
RUN apt-get -y install \
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
    ca-certificates

# Other useful packages
RUN apt-get install -y \
    git \
    osmium-tool \
    pyosmium \
    rsync \
    tmux \
    zsh

RUN git clone https://github.com/taginfo/taginfo-tools.git $workdir/taginfo-tools
WORKDIR $workdir/taginfo-tools
RUN git submodule update --init
RUN  mkdir build && cd build && cmake .. && make
RUN ctest

# COPY config/taginfo-config.json $workdir/
COPY start.sh $workdir/
COPY update.sh $workdir/

WORKDIR $workdir/

# WORKDIR $workdir/taginfo/web
# CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
