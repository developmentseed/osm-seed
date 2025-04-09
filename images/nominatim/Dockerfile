FROM mediagis/nominatim:4.5

RUN apt-get update && \
    apt-get -y install --no-install-recommends \
        cron \
        wget lua5.3 liblua5.3-dev && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Download required Nominatim country grid
RUN mkdir -p /app/Nominatim/data && \
    wget https://www.nominatim.org/data/country_grid.sql.gz -O /app/Nominatim/data/country_osm_grid.sql.gz

COPY docker-entrypoint.sh /app/
COPY update.sh /app/

# Ensure scripts are executable
RUN chmod +x /app/docker-entrypoint.sh /app/update.sh

# Setup cron job
RUN echo "* * * * * cd /app/Nominatim && bash /app/update.sh >> /var/log/cron.log 2>&1" | crontab -

CMD ["/app/docker-entrypoint.sh"]
