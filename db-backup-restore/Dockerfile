FROM ubuntu:16.04
ENV workdir /app
RUN apt-get update
RUN apt-get install -y \
    wget \
    python-pip \
    software-properties-common \
    python-software-properties \
    curl
RUN wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
RUN apt-get update
RUN apt-get install -y postgresql postgresql-contrib
RUN pip install awscli
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN ln -f -s /root/google-cloud-sdk/bin/gsutil /usr/bin/gsutil
WORKDIR $workdir
COPY ./start.sh .
CMD ./start.sh