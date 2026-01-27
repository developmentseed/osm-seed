FROM ruby:3.2-slim AS builder

ARG TAGINFO_TOOLS_VERSION=osmorg-taginfo-live
ARG workdir=/usr/src/app

WORKDIR $workdir

RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    cmake \
    git \
    libbz2-dev \
    libexpat1-dev \
    libgd-dev \
    libicu-dev \
    libosmium2-dev \
    libprotozero-dev \
    libsqlite3-dev \
    zlib1g-dev \
    && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 --branch ${TAGINFO_TOOLS_VERSION} https://github.com/taginfo/taginfo-tools.git $workdir/taginfo-tools && \
    cd $workdir/taginfo-tools && \
    git submodule update --init && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc)

FROM ruby:3.2-slim

ARG TAGINFO_VERSION=osmorg-taginfo-live
ARG workdir=/usr/src/app

WORKDIR $workdir

RUN apt-get update && apt-get install -y --no-install-recommends \
    libbz2-1.0 \
    libexpat1 \
    libgd3 \
    libicu-dev \
    libsqlite3-0 \
    zlib1g \
    curl \
    git \
    jq \
    sqlite3 \
    wget \
    cron \
    unzip \
    build-essential \
    libsqlite3-dev \
    libreadline-dev \
    pkg-config \
    python3-pip \
    uwsgi \
    uwsgi-plugin-ruby \
    && rm -rf /var/lib/apt/lists/*

RUN pip3 install --no-cache-dir --default-timeout=300 --retries 5 awscli --break-system-packages || \
    (sleep 10 && pip3 install --no-cache-dir --default-timeout=300 --retries 5 awscli --break-system-packages)

COPY --from=builder ${workdir}/taginfo-tools ${workdir}/taginfo-tools

RUN git clone --depth 1 --branch ${TAGINFO_VERSION} https://github.com/taginfo/taginfo.git $workdir/taginfo && \
    cd $workdir/taginfo && \
    bundle install --verbose && \
    bundle config set --local deployment 'true' && \
    bundle install --verbose && \
    bundle check && \
    bundle exec ruby -e "require 'sqlite3'; puts 'sqlite3 gem verified'" && \
    sed -i 's|env - \${TAGINFO_RUBY:-ruby}|bundle exec ruby|' $workdir/taginfo/sources/util.sh

RUN gem install --no-document json sqlite3 webrick rack rack-contrib sinatra mustermann rack-protection tilt

RUN mkdir -p $workdir/data $workdir/logs
COPY config/taginfo-config.json $workdir/
COPY start.sh $workdir/
CMD ["/usr/src/app/start.sh"]
