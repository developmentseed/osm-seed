FROM ubuntu:16.04
ENV workdir /app
RUN apt-get update
RUN apt-get install -y \
    wget \
    build-essential \
    python-pip \
    software-properties-common \
    python-software-properties \
    osmosis libz-dev zlib1g-dev \
    curl
RUN pip install awscli
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN ln -f -s /root/google-cloud-sdk/bin/gsutil /usr/bin/gsutil
WORKDIR $workdir
COPY ./start.sh .
CMD ./start.sh