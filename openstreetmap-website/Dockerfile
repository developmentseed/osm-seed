FROM ubuntu:16.04
ENV workdir /var/www

# Production OSM setup
ENV RAILS_ENV=production

# Postgres dependecies
RUN apt-get update
RUN apt-get install -y wget
RUN wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'
RUN apt-get update

# Install the openstreetmap-website dependencies and passenger dependencies
RUN apt-get install -y ruby2.3 libruby2.3 ruby2.3-dev \
    libmagickwand-dev libxml2-dev libxslt1-dev \
    apache2 apache2-dev build-essential git \
    postgresql postgresql-contrib libpq-dev \
    libsasl2-dev imagemagick libffi-dev curl
RUN gem2.3 install bundler

# Install node for some images process dependencies
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# Fixing image_optim issues, installing a bush of libraries from : https://github.com/toy/image_optim#pngout-installation-optional
RUN apt-get install -y advancecomp gifsicle jhead jpegoptim optipng
RUN git clone --recursive https://github.com/kornelski/pngquant.git && \
    cd pngquant && \
    ./configure && \
    make && \
    make install
RUN git clone https://github.com/tjko/jpeginfo.git && \
    cd jpeginfo && \
    ./configure && \
    make && \
    make strip && \
    make install
RUN wget http://iweb.dl.sourceforge.net/project/pmt/pngcrush/1.8.12/pngcrush-1.8.12.tar.gz && \
    tar zxf pngcrush-1.8.12.tar.gz && \
    cd pngcrush-1.8.12 && \
    make && cp -f pngcrush /usr/local/bin
RUN npm install -g svgo

# Install openstreetmap-cgimap
RUN apt-get install -y libxml2-dev libpqxx-dev libfcgi-dev \
    libboost-dev libboost-regex-dev libboost-program-options-dev \
    libboost-date-time-dev libboost-filesystem-dev \
    libboost-system-dev libboost-locale-dev libmemcached-dev \
    libcrypto++-dev automake autoconf libtool libyajl-dev
ENV cgimap /tmp/openstreetmap-cgimap
RUN git clone git://github.com/zerebubuth/openstreetmap-cgimap.git $cgimap
RUN cd $cgimap &&\
    ./autogen.sh &&\
    ./configure &&\
    make &&\
    make install

# Daemontools provides the `fghack` program required for running the `cgimap`
RUN apt-get install -y daemontools

# Install the PGP key and add HTTPS support for APT
RUN apt-get install -y dirmngr gnupg
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
RUN apt-get install -y apt-transport-https ca-certificates

# Add the APT repository
RUN sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list'
RUN apt-get update

# Install Passenger + Apache module
RUN apt-get install -y libapache2-mod-passenger

# Enable the Passenger Apache module and restart Apache
RUN echo "ServerName $(cat /etc/hostname)" >> /etc/apache2/apache2.conf
RUN a2enmod passenger
RUN apache2ctl restart

# Check installation
RUN /usr/bin/passenger-config validate-install
RUN /usr/sbin/passenger-memory-stats

# Clone the openstreetmap-website
RUN rm -rf $workdir
RUN git clone https://github.com/openstreetmap/openstreetmap-website.git $workdir 
WORKDIR $workdir
# gitsha 39f0b501e8cefea961447de9c8076e20fa3adbb4 at Jul 23, 2018
RUN git checkout 39f0b501e8cefea961447de9c8076e20fa3adbb4

# Install the javascript runtime required by the `execjs` gem in
RUN apt-get install -y libv8-dev
RUN echo "gem 'therubyracer'" >> Gemfile

# Install app dependencies
RUN bundle update listen && bundle install

# Configure database.yml, application.yml and secrets.yml
ADD config/database.yml $workdir/config/database.yml
ADD config/application.yml $workdir/config/application.yml
RUN echo "#session key \n\
production: \n\
  secret_key_base: $(bundle exec rake secret)" > $workdir/config/secrets.yml

# Protect sensitive information
RUN chmod 600 $workdir/config/database.yml $workdir/config/application.yml $workdir/config/secrets.yml

# Configure ActionMailer SMTP settings, Replace config/initializers/action_mailer.rb with out configurations
ADD config/action_mailer.rb config/initializers/action_mailer.rb

# Precompile the website assets
RUN bundle exec rake assets:precompile --trace

# The rack interface requires a `tmp` directory to use openstreetmap-cgimap
RUN ln -s /tmp /var/www/tmp

# Add Apache configuration file
ADD config/production.conf /etc/apache2/sites-available/production.conf
RUN a2dissite 000-default
RUN a2ensite production

# Enable required apache modules for the cgimap Apache service
RUN a2enmod proxy proxy_http rewrite

# Config the virtual host apache2
ADD config/cgimap.conf /tmp/
RUN sed -e 's/RewriteRule ^(.*)/#RewriteRule ^(.*)/' \
        -e 's/\/var\/www/\/var\/www\/public/g' \
        /tmp/cgimap.conf > /etc/apache2/sites-available/cgimap.conf
RUN chmod 644 /etc/apache2/sites-available/cgimap.conf
RUN a2ensite cgimap
RUN apache2ctl configtest

# Set Permissions for www-data
RUN chown -R www-data: /var/www

# Script to start the app
ADD start.sh $workdir/start.sh

CMD $workdir/start.sh