FROM python:3.9.9
RUN apt-get update
RUN apt-get install -y \
    curl \
    postgresql-client

# Install AWS CLI
RUN pip install awscli

# Install GCP CLI
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN ln -f -s /root/google-cloud-sdk/bin/gsutil /usr/bin/gsutil

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

VOLUME /mnt/data
COPY ./start.sh /
CMD /start.sh
