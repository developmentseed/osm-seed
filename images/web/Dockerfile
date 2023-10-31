FROM ubuntu:20.04
ENV DEBIAN_FRONTEND=noninteractive
ENV workdir /var/www

# Production OSM setup
ENV RAILS_ENV=production

# Install the openstreetmap-website dependencies
RUN apt-get update \ 
    && apt-get install -y \
    ruby2.7 libruby2.7 ruby2.7-dev libmagickwand-dev libxml2-dev libxslt1-dev \
    nodejs npm apache2 apache2-dev build-essential git-core firefox-geckodriver postgresql-client \
    libpq-dev libsasl2-dev imagemagick libffi-dev libgd-dev libarchive-dev libbz2-dev yarnpkg curl \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install openstreetmap-cgimap requiriments
RUN apt-get update \
    && apt-get -y install \
    libxml2-dev libpqxx-dev libfcgi-dev zlib1g-dev \
    libboost-dev libboost-program-options-dev libboost-filesystem-dev \
    libboost-system-dev libboost-locale-dev libmemcached-dev \
    libcrypto++-dev libargon2-dev libyajl-dev automake autoconf libtool \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
 
# Install cgimap
ENV cgimap /tmp/openstreetmap-cgimap
RUN git clone -b master https://github.com/zerebubuth/openstreetmap-cgimap.git $cgimap
# openstreetmap-cgimap version at Jun 21, 2021
RUN cd $cgimap && git checkout v0.8.6
RUN cd $cgimap && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

# Install svgo required
RUN npm install -g svgo

# Install openstreetmap-website
RUN rm -rf $workdir/html
# GITSHA value at 15-02-2022
ENV OPENSTREETMAP_WEBSITE_GITSHA=c24b5481812aba9e83da1fd855ccb37f92c5d75e
RUN curl -L https://github.com/openstreetmap/openstreetmap-website/archive/$OPENSTREETMAP_WEBSITE_GITSHA.zip --output website.zip && unzip website.zip 
RUN mv openstreetmap-website-$OPENSTREETMAP_WEBSITE_GITSHA/* $workdir/
WORKDIR $workdir
RUN echo "gem 'image_optim_pack', :git => 'https://github.com/toy/image_optim_pack.git'" >> Gemfile

# Install Ruby packages
RUN gem install bundler && bundle install

# Configure database.yml and secrets.yml
RUN cp $workdir/config/example.database.yml $workdir/config/database.yml
RUN touch $workdir/config/settings.local.yml
RUN cp $workdir/config/example.storage.yml $workdir/config/storage.yml
RUN echo "#session key \n\
production: \n\
  secret_key_base: $(bundle exec rake secret)" > $workdir/config/secrets.yml
# Protect sensitive information
RUN chmod 600 $workdir/config/database.yml $workdir/config/secrets.yml
RUN bundle exec rake yarn:install
RUN bundle exec rake i18n:js:export
RUN bundle exec rake assets:precompile

# The rack interface requires a `tmp` directory to use openstreetmap-cgimap
RUN ln -s /tmp /var/www/tmp

# Add Apache configuration file
ADD config/production.conf /etc/apache2/sites-available/production.conf
RUN a2dissite 000-default
RUN a2ensite production

# Install Passenger + Apache module
RUN apt-get update && apt-get install -y libapache2-mod-passenger

# Enable the Passenger Apache module and restart Apache
RUN echo "ServerName $(cat /etc/hostname)" >> /etc/apache2/apache2.conf
RUN a2enmod passenger

# Check installation
RUN /usr/bin/passenger-config validate-install
RUN /usr/sbin/passenger-memory-stats

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
RUN chown -R www-data: $workdir

# Add settings
ADD config/settings.yml $workdir/config/settings.yml

COPY start.sh $workdir/

CMD $workdir/start.sh
