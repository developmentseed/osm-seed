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


RUN ln -s /opt/tegola /usr/bin/tegola

COPY ./config  /opt/config/
COPY build_config.py  /opt/
RUN mkdir /opt/tegola_config
RUN cd /opt/ && python build_config.py \
    --template config/config.template.toml \
    --providers config/providers \
    --output /opt/tegola_config/config.toml

# Copy config and  exec files
COPY ./tile2bounds.py .
COPY ./start.sh .
COPY ./expire-watcher.sh .
COPY ./seed-by-diffs.sh .
COPY ./tile_cache_downloader.sh .
COPY ./rm_tegola_ps.sh .

ENTRYPOINT ["/bin/bash", "-c"]
CMD ./start.sh & ./tile_cache_downloader.sh & ./expire-watcher.sh & ./rm_tegola_ps.sh
