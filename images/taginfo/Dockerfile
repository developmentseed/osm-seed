# Build stage for taginfo-tools
FROM ruby:3.2-slim AS builder

ARG TAGINFO_TOOLS_VERSION=osmorg-taginfo-live
ARG workdir=/usr/src/app

WORKDIR $workdir

# Install build dependencies
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

# Clone and build taginfo-tools
RUN git clone --depth 1 --branch ${TAGINFO_TOOLS_VERSION} https://github.com/taginfo/taginfo-tools.git $workdir/taginfo-tools && \
    cd $workdir/taginfo-tools && \
    git submodule update --init && \
    mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release .. && \
    make -j$(nproc)

# Final stage
FROM ruby:3.2-slim

ARG TAGINFO_VERSION=osmorg-taginfo-live
ARG workdir=/usr/src/app

WORKDIR $workdir

# Install runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Runtime libraries
    libbz2-1.0 \
    libexpat1 \
    libgd3 \
    libicu-dev \
    libsqlite3-0 \
    zlib1g \
    # Tools needed at runtime
    curl \
    git \
    jq \
    sqlite3 \
    wget \
    cron \
    # Build tools for gems with native extensions
    build-essential \
    libsqlite3-dev \
    libreadline-dev \
    pkg-config \
    # Python
    python3-pip \
    # uWSGI with Ruby/Rack support
    uwsgi \
    uwsgi-plugin-ruby \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI with retry logic and increased timeout
RUN pip3 install --no-cache-dir --default-timeout=300 --retries 5 awscli --break-system-packages || \
    (sleep 10 && pip3 install --no-cache-dir --default-timeout=300 --retries 5 awscli --break-system-packages)

# Build and install PCRE (required for sqlite3-pcre)
# PCRE3 is no longer available in Debian 12+, so we compile it from source
RUN wget https://sourceforge.net/projects/pcre/files/pcre/8.45/pcre-8.45.tar.gz/download -O /tmp/pcre-8.45.tar.gz && \
    cd /tmp && tar -xzf pcre-8.45.tar.gz && \
    cd pcre-8.45 && \
    ./configure --prefix=/usr/local --enable-utf8 --enable-unicode-properties && \
    make -j$(nproc) && \
    make install && \
    ldconfig && \
    rm -rf /tmp/pcre*

# Build and install sqlite3-pcre extension
# Compile directly with PCRE libraries we built
RUN git clone --depth 1 https://github.com/ralight/sqlite3-pcre.git /tmp/sqlite3-pcre && \
    cd /tmp/sqlite3-pcre && \
    cc -shared -o pcre.so -fPIC -W pcre.c \
       -I/usr/local/include \
       -L/usr/local/lib \
       -lpcre && \
    mkdir -p /usr/lib/sqlite3 && \
    cp pcre.so /usr/lib/sqlite3/ && \
    rm -rf /tmp/sqlite3-pcre

# Copy built taginfo-tools from builder stage
COPY --from=builder ${workdir}/taginfo-tools ${workdir}/taginfo-tools

# Clone taginfo and install dependencies
RUN git clone --depth 1 --branch ${TAGINFO_VERSION} https://github.com/taginfo/taginfo.git $workdir/taginfo && \
    cd $workdir/taginfo && \
    bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install

# Install additional Ruby gems needed
RUN gem install --no-document json rack-contrib

# Create data directories
RUN mkdir -p $workdir/data $workdir/logs

# Copy configuration files and scripts
COPY config/taginfo-config.json $workdir/
COPY start.sh $workdir/

RUN chmod +x $workdir/start.sh

# Expose port
EXPOSE 80

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:80/ || exit 1

CMD ["./start.sh"]
