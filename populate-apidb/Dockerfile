FROM ubuntu:16.04
ENV workdir /app
RUN apt-get update
RUN apt-get install -y \
    wget \
    build-essential \
    python-pip \
    software-properties-common \
    python-software-properties \
    libz-dev zlib1g-dev \
    curl unzip \
    gdal-bin tar \
    bzip2 clang git \
    default-jre default-jdk gradle
RUN wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
RUN apt-get update
RUN apt-get install -y postgresql postgresql-contrib
RUN pip install awscli
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN ln -f -s /root/google-cloud-sdk/bin/gsutil /usr/bin/gsutil
# Install osmosis
RUN git clone https://github.com/openstreetmap/osmosis.git
WORKDIR osmosis
RUN git checkout 9cfb8a06d9bcc948f34a6c8df31d878903d529fc
RUN mkdir dist
RUN ./gradlew assemble
RUN tar -xvzf "$PWD"/package/build/distribution/*.tgz -C "$PWD"/dist/
RUN ln -s "$PWD"/dist/bin/osmosis /usr/bin/osmosis
RUN osmosis --version 2>&1 | grep "Osmosis Version"
WORKDIR $workdir
COPY ./start.sh .
CMD ./start.sh