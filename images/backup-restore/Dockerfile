FROM python:3.9.9
ENV workdir /app
RUN apt-get update
RUN apt-get install -y \
    curl \
    postgresql-client

# Install AWS and GCP cli
RUN pip install awscli
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN ln -f -s /root/google-cloud-sdk/bin/gsutil /usr/bin/gsutil
WORKDIR $workdir
COPY ./start.sh .
CMD ./start.sh
