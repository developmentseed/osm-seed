FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y -qq && \
    apt-get install -y curl python3 \
    python3-dev python3-pip git libgeos-dev \
    libcurl4-gnutls-dev librtmp-dev python3-gdal \
    libyaml-dev locales && \
    locale-gen en_US.UTF-8 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Setting locale is required by unicode-slugify (osmcha-django python requirement)
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

WORKDIR /app
ENV BACKEND_VERSION feature/osm-server-config
RUN git clone https://github.com/willemarcel/osmcha-django .
RUN git checkout $BACKEND_VERSION
RUN git pull origin $BACKEND_VERSION
RUN pip3 install -r requirements/production.txt
RUN pip3 install -r requirements/local.txt

# Replace social-auth-core by a modified version that provides OHM authentication
RUN pip3 install git+https://github.com/OpenHistoricalMap/social-core.git@master

# Upgrading requests to the latest version.
RUN pip3 install -U requests
RUN pip3 install certifi
RUN pip3 install django-extensions
ADD . /app

ENV DJANGO_ROOT /app
ENV DJANGO_SETTINGS_MODULE config.settings.production
ENV C_FORCE_ROOT True
ENV OSMCHA_FRONTEND_VERSION v0.86.0-production

RUN echo "alias python=python3" >> ~/.bashrc
RUN echo "alias pip=pip3" >> ~/.bashrc

COPY ./start.sh .
CMD ./start.sh