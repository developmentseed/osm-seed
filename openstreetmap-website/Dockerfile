FROM ubuntu:16.04
ENV workdir /var/www

# Production OSM setup
ENV RAILS_ENV=production

# Install the openstreetmap-website dependencies and passenger dependencies
RUN apt-get update && \
    apt-get install -y wget curl \
    build-essential git git-core \
    zlib1g-dev libssl-dev libreadline-dev libyaml-dev \
    libsqlite3-dev sqlite3 libmagickwand-dev libxml2-dev libxslt1-dev \
    openssh-server openssh-client \
    apache2 apache2-dev \
    libsasl2-dev imagemagick libffi-dev postgresql-client curl &&\
    # Cleanup
    apt-get clean && \
    cd /var/lib/apt/lists && rm -fr *Release* *Sources* *Packages* && \
    truncate -s 0 /var/log/*log

# Install Ruby 2.4.1
RUN cd /tmp &&\
  wget -O ruby-2.4.1.tar.gz https://cache.ruby-lang.org/pub/ruby/2.4/ruby-2.4.1.tar.gz &&\
  tar -xzvf ruby-2.4.1.tar.gz &&\
  cd ruby-2.4.1/ &&\
  ./configure &&\
  make &&\
  make install &&\
  cd /tmp &&\
  rm -rf ruby-2.4.1 &&\
  rm -rf ruby-2.4.1.tar.gz

# Add Ruby binaries and gem to $PATH 
ENV PATH /usr/local/bin/:$PATH
ENV WORK_ROOT /var
ENV GEM_HOME $WORK_ROOT/.gem/ruby
ENV GEM_PATH $GEM_HOME
ENV PATH $PATH:$GEM_PATH/bin

# Add options to gemrc
RUN echo "gem: --no-document" > $WORK_ROOT/.gemrc
RUN apt-get -y update && \
    apt-get -y upgrade


RUN gem install bundler

RUN ln -s /usr/local/lib/libcrypto.so.1.0.0 /usr/lib/libcrypto.so.1.1

# Install node for some images process dependencies
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs

# Fixing image_optim issues, installing a bush of libraries from : https://github.com/toy/image_optim#pngout-installation-optional
RUN apt-get install -y advancecomp gifsicle jhead jpegoptim optipng
RUN git clone -b 2.12.2 https://github.com/kornelski/pngquant.git && \
    cd pngquant && \
    ./configure && \
    make && \
    make install
RUN git clone https://github.com/tjko/jpeginfo.git && \
    cd jpeginfo && \
    git checkout 743b1b15002f05298a0672e9d0f23ada240ababf && \
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
RUN git clone -b v0.6.2 https://github.com/zerebubuth/openstreetmap-cgimap.git $cgimap
RUN cd $cgimap && \
    ./autogen.sh && \
    ./configure && \
    make && \
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
RUN echo 'clone the repo'
RUN git clone https://github.com/OpenHistoricalMap/ohm-website.git $workdir
WORKDIR $workdir
RUN git checkout 283d7ea5214814249bd01ed836c1adb2883217fa

# Install the javascript runtime required by the `execjs` gem in
RUN apt-get install -y libv8-dev
RUN echo "gem 'therubyracer'" >> Gemfile

RUN gem install nokogiri -- --use-system-libraries

# Install app dependencies
RUN bundle update listen && bundle install

# update vendored iD
RUN rm -rf vendor/assets/iD
RUN vendorer

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
RUN apt-get install -y tzdata
# gem install tzinfo-data

# RUN bundle exec rake assets:precompile --trace
RUN bundle exec rake i18n:js:export --trace

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
RUN npm install yarn -g

# Set Permissions for www-data
RUN chown -R www-data: /var/www

# Script to start the app
ADD start.sh $workdir/start.sh

CMD $workdir/start.sh
