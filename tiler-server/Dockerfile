FROM gospatial/tegola:v0.8.1
# Volumen
ENV CACHEDATA /mnt/data
RUN mkdir -p "$CACHEDATA" && chmod 777 "$CACHEDATA"
VOLUME /mnt/data
COPY ./config/config.toml  /opt/tegola_config/config.toml
COPY ./start.sh ./start.sh
CMD ./start.sh