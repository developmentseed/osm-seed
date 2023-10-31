FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt-get update -qq -y
RUN apt-get install -y curl wget python3 python3-dev python3-pip git libgeos-dev libcurl4-gnutls-dev librtmp-dev python3-gdal libyaml-dev locales nginx supervisor postgresql-client libpq-dev python3-pyproj
RUN apt-get install -y libproj-dev binutils

ENV workdir /usr/src/app

RUN git clone https://github.com/hotosm/tasking-manager.git $workdir
# Commits on Oct 23, 2020
RUN cd $workdir && git checkout -f 951039f86938b9cc9d8b6986c4e5f3423a78e4d3
WORKDIR $workdir

RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install -r requirements.txt
RUN pip3 install apscheduler==3.7.0

## INITIALIZATION
EXPOSE 5000
CMD ["gunicorn", "-b", "0.0.0.0:5000", "--worker-class", "gevent", "--workers", "3", \
    "--threads", "3", "--timeout", "179", "manage:application", "&"]
