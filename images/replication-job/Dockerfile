FROM debian:bookworm AS builder

# Setup PostgreSQL repository and install build dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
 && . /etc/os-release \
 && echo "deb http://apt.postgresql.org/pub/repos/apt ${VERSION_CODENAME}-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
 && curl -fsSL https://www.postgresql.org/media/keys/ACCC4CF8.asc | gpg --dearmor -o /etc/apt/trusted.gpg.d/postgresql.gpg \
 && apt-get update \
 && apt-get install -y --no-install-recommends \
    git build-essential cmake pandoc \
    libosmium2-dev libprotozero-dev libyaml-cpp-dev \
    libpqxx-6.4 libpqxx-dev \
    libboost-program-options-dev libboost-system-dev libboost-filesystem-dev \
    postgresql-server-dev-17 libbz2-dev libexpat1-dev zlib1g-dev \
 && rm -rf /var/lib/apt/lists/*

# Build osmdbt
RUN git clone https://github.com/openstreetmap/osmdbt.git /osmdbt \
 && cd /osmdbt && git checkout v0.9 \
 && mkdir -p build && cd build \
 && cmake -DBUILD_PLUGIN=OFF .. && make

RUN mkdir -p /tmp/runtime-libs \
 && find /usr/lib/x86_64-linux-gnu /usr/local/lib -name "libosmium*.so*" -exec cp {} /tmp/runtime-libs/ \; 2>/dev/null || true \
 && find /usr/lib/x86_64-linux-gnu /usr/local/lib -name "libprotozero*.so*" -exec cp {} /tmp/runtime-libs/ \; 2>/dev/null || true

# ============================================================================
# Runtime stage
# ============================================================================
FROM debian:bookworm

# Install runtime dependencies
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
    ca-certificates curl gzip bash procps postgresql-client \
    openjdk-17-jre-headless osmosis awscli \
    libpqxx-6.4 libyaml-cpp0.7 \
    libboost-program-options1.74.0 libboost-system1.74.0 libboost-filesystem1.74.0 \
    libbz2-1.0 libexpat1 zlib1g \
 && rm -rf /var/lib/apt/lists/*

# Copy binaries and third-party libraries (libosmium, libprotozero from builder)
COPY --from=builder /osmdbt/build /osmdbt/build
COPY --from=builder /usr/local/bin /usr/local/bin
COPY --from=builder /tmp/runtime-libs/ /usr/local/lib/

RUN ldconfig

ENV PATH="/osmdbt/build:/usr/local/bin:$PATH"

COPY start.sh /start.sh
COPY liveness.sh /liveness.sh
ENTRYPOINT ["/bin/bash","-c"]
CMD ["/start.sh"]
