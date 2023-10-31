FROM ubuntu:20.04
ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update -y -qq
RUN apt-get install -y curl python3 python3-dev \
    python3-pip git libgeos-dev libyaml-dev \
    libcurl4-gnutls-dev librtmp-dev python3-gdal \
    locales nginx supervisor yarnpkg nodejs npm
RUN locale-gen en_US.UTF-8
RUN apt-get clean
RUN rm -rf /var/lib/apt/lists/*

# Install yarn.
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update -y
RUN apt-get remove -y yarnpkg cmdtest && apt-get install -y yarn && apt-get clean && rm -rf /var/lib/apt/lists/*

# Setup nginx
RUN rm /etc/nginx/sites-enabled/default
COPY django.conf /etc/nginx/sites-available/
RUN ln -s /etc/nginx/sites-available/django.conf /etc/nginx/sites-enabled/django.conf
RUN echo "daemon off;" >> /etc/nginx/nginx.conf


# Setting locale is required by unicode-slugify (osmcha-django python requirement)
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en

WORKDIR /app
ENV BACKEND_VERSION v4.19.0
RUN git clone https://github.com/willemarcel/osmcha-django .
RUN git checkout $BACKEND_VERSION
RUN git pull origin $BACKEND_VERSION
RUN pip3 install -r requirements/production.txt
RUN pip3 install -r requirements/local.txt

ADD . /app
ENV DJANGO_ROOT /app
ENV DJANGO_SETTINGS_MODULE config.settings.aws_production

# Replace social-auth-core by a modified version that provides OHM authentication
RUN pip3 install git+https://github.com/OpenHistoricalMap/social-core.git@master

# Upgrading requests to the latest version.
RUN pip3 install -U requests
RUN pip3 install certifi
RUN pip3 install django-extensions

# Clone and build the frontend
RUN git clone https://github.com/mapbox/osmcha-frontend.git /osmcha-frontend
RUN cd /osmcha-frontend && yarn install

RUN echo "alias python=python3" >> ~/.bashrc
RUN echo "alias pip=pip3" >> ~/.bashrc

EXPOSE 80

# Supervisor config
RUN mkdir -p /var/log/supervisor
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY gunicorn.conf /etc/supervisor/conf.d/gunicorn.conf

COPY ./start.sh .
CMD ./start.sh
