FROM golang:1.14.1-alpine3.11 AS build
ENV VERSION="v0.8.1"
RUN apk update

RUN apk add musl-dev=1.1.24-r2 \
	gcc=9.3.0-r0 \
    bash \
    git \
    postgresql \
    postgresql-contrib

RUN mkdir -p /go/src/github.com/go-spatial/tegola
RUN git clone https://github.com/go-spatial/tegola.git /go/src/github.com/go-spatial/tegola
RUN cd /go/src/github.com/go-spatial/tegola && git checkout v0.8.1
RUN cd /go/src/github.com/go-spatial/tegola/cmd/tegola \
	&& go build -gcflags "-N -l" -o /opt/tegola \ 
	&& chmod a+x /opt/tegola
RUN ln -s /opt/tegola /usr/bin/tegola

RUN apk add --update \
    python \
    py-pip \
    py-cffi \
    py-cryptography \
  && pip install --upgrade pip \
  && apk add --virtual build-deps \
    gcc \
    libffi-dev \
    python-dev \
    linux-headers \
    musl-dev \
    openssl-dev

# Install aws-cli and  gsutil
RUN pip install awscli \
    && pip install gsutil

RUN pip install mercantile \
    && apk del build-deps \
    && rm -rf /var/cache/apk/* \
    && apk --purge -v del py-pip

RUN apk add --update coreutils jq && rm -rf /var/cache/apk/*

# Volumen
VOLUME /mnt/data
# Copy config and  exec files
COPY ./config/config.toml  /opt/tegola_config/config.toml
COPY ./tile2bounds.py .
COPY ./start.sh .
COPY ./expire-watcher.sh .
COPY ./seed-by-diffs.sh .
COPY ./tile_cache_downloader.sh .
CMD ./start.sh & ./tile_cache_downloader.sh & ./expire-watcher.sh
