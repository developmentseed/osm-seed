FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV workdir /var/www
ENV RAILS_ENV=production

# Install system packages then clean up to minimize image size
RUN apt-get update \
  && apt-get install --no-install-recommends -y \
  build-essential \
  curl \
  default-jre-headless \
  file \
  git-core \
  gpg-agent \
  libarchive-dev \
  libffi-dev \
  libgd-dev \
  libpq-dev \
  libsasl2-dev \
  libvips-dev \
  libxml2-dev \
  libxslt1-dev \
  libyaml-dev \
  locales \
  postgresql-client \
  ruby \
  ruby-dev \
  ruby-bundler \
  software-properties-common \
  tzdata \
  unzip \
  apache2 \
  apache2-dev \
  libyaml-dev \
  && add-apt-repository -y ppa:mozillateam/ppa \
  && echo "Package: *\nPin: release o=LP-PPA-mozillateam\nPin-Priority: 1001" > /etc/apt/preferences.d/mozilla-firefox \
  && apt-get install --no-install-recommends -y \
  firefox-geckodriver \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install node
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y nodejs yarn && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install openstreetmap-cgimap requirements
RUN apt-get update &&  apt-get -y install libpqxx-dev libfcgi-dev zlib1g-dev \
  libboost-dev libboost-program-options-dev libfmt-dev \
  libmemcached-dev libcrypto++-dev libargon2-dev libyajl-dev \
  automake autoconf libtool && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

# Install cgimap
ENV cgimap /tmp/openstreetmap-cgimap
ENV CGIMAP_GITSHA=5cd3d21bebe9d205828608be4c65bbda8b464308
RUN git clone -b master https://github.com/zerebubuth/openstreetmap-cgimap.git $cgimap
RUN cd $cgimap && git checkout $CGIMAP_GITSHA
RUN cd $cgimap && \
  ./autogen.sh && \
  ./configure && \
  make && \
  make install

# Install node
RUN curl -sL https://deb.nodesource.com/setup_18.x | bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y nodejs yarn && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*



RUN mkdir -p $workdir/
ENV OPENSTREETMAP_WEBSITE_GITSHA=6c03ef52bdba8c2b1549cb5baad8bcbb0fb48864
RUN curl -L https://github.com/openstreetmap/openstreetmap-website/archive/$OPENSTREETMAP_WEBSITE_GITSHA.zip --output website.zip && unzip website.zip 
RUN mv openstreetmap-website-$OPENSTREETMAP_WEBSITE_GITSHA/* $workdir/
WORKDIR $workdir

# # change the echo here with a reason for changing the commithash
# RUN echo 'update map style'
# RUN git fetch

# Install Ruby packages
RUN gem update bundler
RUN bundle install
RUN bundle exec bin/yarn install

# Configure database.yml and secrets.yml
RUN cp $workdir/config/example.database.yml $workdir/config/database.yml
RUN touch $workdir/config/settings.local.yml
RUN cp $workdir/config/example.storage.yml $workdir/config/storage.yml
RUN echo "export SECRET_KEY_BASE=\$(bundle exec rake secret)" >> /etc/profile
ENV SECRET_KEY_BASE=${SECRET_KEY_BASE}

RUN echo "#session key \n\
  production: \n\
  secret_key_base: ${SECRET_KEY_BASE}" > $workdir/config/secrets.yml
# Protect sensitive information
RUN chmod 600 $workdir/config/database.yml $workdir/config/secrets.yml

RUN yarn install
RUN bundle exec rake yarn:install
# RUN bundle exec rake i18n:js:export
# RUN bundle exec rake assets:precompile

RUN apt-get update && apt-get install -y libapache2-mod-passenger

# The rack interface requires a `tmp` directory to use openstreetmap-cgimap
RUN ln -s /tmp /var/www/tmp

# Add Apache configuration file
ADD config/production.conf /etc/apache2/sites-available/production.conf
RUN a2enmod headers
RUN a2enmod setenvif
RUN a2dissite 000-default
RUN a2ensite production

# Enable the Passenger Apache module and restart Apache
RUN echo "ServerName $(cat /etc/hostname)" >> /etc/apache2/apache2.conf
RUN a2enmod passenger

# Check installation
RUN /usr/bin/passenger-config validate-install
RUN /usr/sbin/passenger-memory-stats

# Enable required apache modules for the cgimap Apache service
RUN a2enmod proxy proxy_http rewrite lbmethod_byrequests proxy_fcgi

# Config the virtual host apache2
RUN apache2ctl configtest

# Set Permissions for www-data
RUN chown -R www-data: $workdir

# Add settings
ADD config/settings.yml $workdir/config/

COPY start.sh $workdir/
COPY liveness.sh $workdir/

CMD $workdir/start.sh
