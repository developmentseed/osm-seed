FROM ubuntu:16.04
RUN apt-get update
ENV _LARGEFILE64_SOURCE=1
ENV _LFS64_LARGEFILE=1
RUN apt-get install -y wget build-essential python-pip software-properties-common python-software-properties osmosis 
RUN pip install awscli
RUN mkdir -p osmosis

WORKDIR osmosis/
COPY ./import_osm.sh .

CMD ./import_osm.sh