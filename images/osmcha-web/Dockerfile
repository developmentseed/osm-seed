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
ENV BACKEND_VERSION v4.17.0
RUN git clone https://github.com/willemarcel/osmcha-django .
RUN git checkout $BACKEND_VERSION
RUN pip3 install -r requirements/production.txt
RUN pip3 install -r requirements/local.txt

RUN curl -o /usr/local/bin/watchbot https://s3.amazonaws.com/watchbot-binaries/linux/v5.0.0/watchbot
RUN chmod +x /usr/local/bin/watchbot

# Upgrading requests to the latest version.
RUN pip3 install -U requests
RUN pip3 install certifi
RUN pip3 install django-extensions
ADD . /app

# Install decrypt-kms-env
RUN curl -sL https://github.com/mapbox/decrypt-kms-env/archive/v1.0.3.tar.gz | tar --gunzip --extract --strip-components=1 --exclude=readme.md --directory=/usr/local

ENV DJANGO_ROOT /app
ENV DJANGO_SETTINGS_MODULE config.settings.production
ENV C_FORCE_ROOT True

RUN echo "alias python=python3" >> ~/.bashrc
RUN echo "alias pip=pip3" >> ~/.bashrc

COPY ./start.sh .
CMD ./start.sh