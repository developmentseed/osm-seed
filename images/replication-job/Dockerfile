FROM debian:bookworm

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
   ca-certificates \
   git \
   curl \
   gzip \
   bash \
   procps \
   openjdk-17-jre-headless \
   osmosis \
   postgresql-client \
   # Build deps for osmdbt (keep if you really need osmdbt built in this image)
   build-essential \
   cmake \
   gettext-base \
   libboost-program-options-dev \
   libbz2-dev \
   libexpat1-dev \
   libosmium2-dev \
   libprotozero-dev \
   libyaml-cpp-dev \
   libpqxx-dev \
   pandoc \
   postgresql-common \
   postgresql-server-dev-17 \
   zlib1g-dev \
   && update-ca-certificates \
   && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/openstreetmap/osmdbt.git /osmdbt && cd /osmdbt && git checkout v0.9
WORKDIR /osmdbt
RUN mkdir -p build && cd build && cmake .. && make
RUN cd /osmdbt/build && find . -type f -executable -name "osmdbt*" -exec cp {} /usr/local/bin/ \; || true
ENV PATH="/osmdbt/build:/usr/local/bin:$PATH"

# --- Build and store the osm_logical.so plugin for PostgreSQL ---
RUN cd /osmdbt/postgresql-plugin && \
   mkdir -p build && \
   cd build && \
   cmake .. && \
   make && \
   # Copia cualquier archivo .so producido a una ruta neutral fácil de extraer luego
   mkdir -p /usr/local/lib/osmdbt-plugin && \
   find . -name "*.so" -exec cp {} /usr/local/lib/osmdbt-plugin/ \;

RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    awscli \
 && rm -rf /var/lib/apt/lists/*

COPY start.sh /start.sh

ENTRYPOINT ["/bin/bash","-c"]
CMD ["/start.sh"]
