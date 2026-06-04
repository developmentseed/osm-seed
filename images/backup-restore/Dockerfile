FROM python:3.9.9-slim

# Install Postgres client 17 and ZSTD compression tools
RUN apt-get update \
    && apt-get install -y curl apt-transport-https lsb-release gnupg \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && curl -L https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && apt-get update \
    && apt-get install -y postgresql-client-17 wget zstd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN pip install awscli

COPY ./start.sh /
CMD ["/start.sh"]
