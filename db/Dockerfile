FROM postgres:10
RUN apt-get update
RUN apt-get install -y make \
    postgresql-server-dev-all \
    build-essential \
    && apt-get clean && rm -rf /var/lib/apt/lists/*
RUN mkdir -p db
RUN mkdir -p lib
ADD docker_postgres.sh docker-entrypoint-initdb.d/docker_postgres.sh
ADD functions/ db/functions/
ADD lib/quad_tile/ lib/quad_tile/
RUN make -C db/functions/
RUN chown -R postgres lib/
RUN chown -R postgres db/