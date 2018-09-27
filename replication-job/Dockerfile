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
    bzip2 clang git

RUN apt-get -y install default-jre default-jdk gradle
RUN pip install awscli
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN ln -f -s /root/google-cloud-sdk/bin/gsutil /usr/bin/gsutil
RUN git clone https://github.com/openstreetmap/osmosis.git
WORKDIR osmosis
RUN git checkout e344f05d4cffbd70801a5c50af02b409a7d2adfc
RUN ./gradlew assemble
RUN ln -s "$PWD"/package/bin/osmosis /usr/bin/osmosis
RUN osmosis --version 2>&1 | grep "Osmosis Version"
WORKDIR $workdir
RUN mkdir data
VOLUME ["/app/data"]
COPY ./start.sh .
CMD ./start.sh