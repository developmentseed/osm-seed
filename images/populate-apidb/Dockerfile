FROM debian:bookworm-slim

ENV workdir=/mnt/data
WORKDIR $workdir

RUN set -ex \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        gnupg \
        lsb-release \
        wget \
        bzip2 \
        osmosis \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ bookworm-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && curl -L https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        postgresql-client-17 \
    && rm -rf /var/lib/apt/lists/*

VOLUME /mnt/data
COPY ./start.sh /
RUN chmod +x /start.sh
CMD ["/start.sh"]
