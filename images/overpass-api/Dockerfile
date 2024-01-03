FROM wiktorn/overpass-api:0.7.56.8
COPY docker-entrypoint.sh /app/
RUN chmod a+rx /app/docker-entrypoint.sh 
CMD ["/app/docker-entrypoint.sh & sleep 60 && /app/bin/dispatcher --osm-base --db-dir=/db/db --attic"]
