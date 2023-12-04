FROM postgres:14
# Install PostGIS
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    postgis \
    postgresql-14-postgis-3 && \
    rm -rf /var/lib/apt/lists/*
# Initialize PostGIS
COPY init-postgis.sql /docker-entrypoint-initdb.d/
