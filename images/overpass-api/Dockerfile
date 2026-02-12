FROM wiktorn/overpass-api:0.7.62
COPY *.sh /app/
RUN chmod +x /app/docker-entrypoint.sh /app/fix-permissions.sh
ENTRYPOINT ["/app/docker-entrypoint.sh"]
