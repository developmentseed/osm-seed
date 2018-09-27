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
    curl openjdk-8-jdk

RUN pip install awscli
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN ln -f -s /root/google-cloud-sdk/bin/gsutil /usr/bin/gsutil
# RUN wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o osmconvert
# RUN cp osmconvert /usr/bin/osmconvert
RUN wget https://bretth.dev.openstreetmap.org/osmosis-build/osmosis-latest.tgz
RUN mkdir osmosis
RUN mv osmosis-latest.tgz osmosis
WORKDIR osmosis
RUN tar xvfz osmosis-latest.tgz
RUN rm osmosis-latest.tgz
RUN chmod a+x bin/osmosis
RUN cp bin/osmosis /usr/bin/
WORKDIR $workdir
RUN mkdir data
VOLUME ["/app/data"]
COPY ./start.sh .
CMD ./start.sh