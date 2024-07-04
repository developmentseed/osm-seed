FROM gospatial/tegola:v0.20.0

RUN apk --no-cache add \
    gcc \
    libffi-dev \
    python3 \
    py3-pip \
    py3-cffi \
    py3-cryptography \
    linux-headers \
    musl-dev \
    openssl-dev \
    bash \
    git \
    postgresql-client \
    coreutils \
    jq

RUN pip install --upgrade pip && pip3 install awscli mercantile 

# Volumen
VOLUME /mnt/data
# Copy config and  exec files
COPY ./config/config.toml  /opt/tegola_config/config.toml
COPY ./tile2bounds.py .
COPY ./start.sh .
COPY ./expire-watcher.sh .
COPY ./seed-by-diffs.sh .
COPY ./tile_cache_downloader.sh .
COPY ./rm_tegola_ps.sh .

CMD ./start.sh & ./tile_cache_downloader.sh & ./expire-watcher.sh & ./rm_tegola_ps.sh
