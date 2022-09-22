FROM mediagis/nominatim:4.1
ENV PGDATA=/var/lib/postgresql/12/main
COPY docker-entrypoint.sh /app/
RUN chmod a+rx /app/docker-entrypoint.sh 
CMD ["/app/docker-entrypoint.sh"]
