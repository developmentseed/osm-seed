FROM ubuntu:16.04
RUN apt-get update
RUN apt-get install -y wget build-essential python-pip software-properties-common python-software-properties osmosis libz-dev zlib1g-dev
RUN pip install awscli
RUN mkdir -p osmosis
WORKDIR osmosis/
RUN wget -O - http://m.m.i24.cc/osmconvert.c | cc -x c - -lz -O3 -o osmconvert
RUN cp osmconvert /usr/bin/osmconvert
COPY ./script.sh .
CMD ./script.sh