FROM ubuntu:16.04

ENV workdir /app

RUN apt-get update
RUN apt-get install -y wget python-pip software-properties-common python-software-properties 
RUN wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
RUN apt-get update
RUN apt-get install -y  postgresql postgresql-contrib
RUN pip install awscli

WORKDIR $workdir
ADD script.sh $workdir/script.sh
RUN apt-get install -y nano
CMD ./script.sh