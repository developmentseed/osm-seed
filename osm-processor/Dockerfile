FROM ubuntu:16.04
ENV workdir /app
RUN apt-get update
RUN apt-get -y install \
    build-essential \
    libboost-program-options-dev \
    libbz2-dev \
    zlib1g-dev \
    libexpat1-dev \
    cmake \
    pandoc \
    git \
    python-pip \
    curl \
    unzip \
    wget

RUN git clone https://github.com/mapbox/protozero
RUN cd protozero && git checkout 23d48fd2a441c6e3b2852ff84a0ba398e48f74be && mkdir build && cd build && cmake .. && make && make install
RUN git clone https://github.com/osmcode/libosmium
RUN cd libosmium && git checkout a1f88fe44b01863a1ac84efccff54b98bb2dc886 && mkdir build && cd build && cmake .. && make && make install
RUN git clone https://github.com/osmcode/osmium-tool
RUN cd osmium-tool && git checkout ddbcb44f3ec0c1a8d729e69e3cee40d25f5a00b4 && mkdir build && cd build && cmake .. && make && make install

RUN pip install awscli
RUN curl -sSL https://sdk.cloud.google.com | bash
RUN ln -f -s /root/google-cloud-sdk/bin/gsutil /usr/bin/gsutil

WORKDIR $workdir
RUN mkdir data
COPY ./start.sh .
CMD ./start.sh