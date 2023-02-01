FROM mediagis/nominatim:4.1
RUN apt-get update && \
        apt-get -y install \
        build-essential \
        g++ \
        cmake \
        libpq-dev \
        zlib1g-dev \
        libbz2-dev \
        libproj-dev \
        libexpat1-dev \
        libboost-dev \
        libboost-system-dev \
        libboost-filesystem-dev \
        git \
        wget \
        cron
# Nominatim install.
RUN true \
    && git clone https://github.com/osm-search/Nominatim.git \
    && cd Nominatim \
    && git checkout v4.1.0 \
    && git submodule update --init
COPY settings/placex_triggers.sql /app/Nominatim/lib-sql/functions/
RUN wget -O Nominatim/data/country_osm_grid.sql.gz https://www.nominatim.org/data/country_grid.sql.gz
RUN mkdir build \
    && cd build \
    && cmake ../Nominatim \
    && make -j`nproc` \
    && make install

RUN true \
    # Remove development and unused packages.
    && apt-get -y remove --purge \
        cpp-9 \
        gcc-9* \
        g++ \
        git \
        make \
        cmake* \
        llvm-10* \
        libc6-dev \
        linux-libc-dev \
        libclang-*-dev \
        build-essential \
        postgresql-server-dev-14 \
    && apt-get clean \
    # Clear temporary files and directories.
    && rm -rf \
        /tmp/* \
        /var/tmp/* \
        /root/.cache \
        /app/src/.git \
        /var/lib/apt/lists/* \

ENV PGDATA=/var/lib/postgresql/14/main
COPY docker-entrypoint.sh /app/
COPY update.sh /app/
RUN crontab -l | { cat; echo "* * * * * cd /nominatim/ ; bash /app/update.sh >> /var/log/cron.log 2>&1"; } | crontab -
CMD ["/app/docker-entrypoint.sh"]
