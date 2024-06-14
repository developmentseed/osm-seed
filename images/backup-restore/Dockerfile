FROM python:3.9.9-slim

# Install Postgres client, GCP CLI, and Azure CLI
RUN apt-get update \
    && apt-get install -y curl apt-transport-https lsb-release gnupg \
    && echo "deb http://apt.postgresql.org/pub/repos/apt/ bullseye-pgdg main" > /etc/apt/sources.list.d/pgdg.list \
    && curl -L https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - \
    && curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && apt-get update \
    && apt-get install -y postgresql-client-14 wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install GCP CLI
RUN curl -sSL https://sdk.cloud.google.com | bash \
    && ln -f -s /root/google-cloud-sdk/bin/gsutil /usr/bin/gsutil
RUN rm -rf /root/google-cloud-sdk/.install/.backup

# Install AWS CLI
RUN pip install awscli

COPY ./start.sh /
CMD ["/start.sh"]
