FROM ubuntu:16.04
# FROM https://www.phusionpassenger.com/library/walkthroughs/deploy/ruby/ownserver/apache/oss/xenial/deploy_app.html
ENV workdir /var/www

ENV RAILS_ENV=production

RUN apt-get update

RUN apt-get install -y wget

RUN wget -q https://www.postgresql.org/media/keys/ACCC4CF8.asc -O - | apt-key add -

RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt/ xenial-pgdg main" >> /etc/apt/sources.list.d/pgdg.list'

RUN apt-get update

RUN apt-get install -y ruby2.3 libruby2.3 ruby2.3-dev \
                     libmagickwand-dev libxml2-dev libxslt1-dev nodejs \
                     apache2 apache2-dev build-essential git-core \
                     postgresql postgresql-contrib libpq-dev \
                     libsasl2-dev imagemagick libffi-dev \
                     dirmngr gnupg git \
                     nano

# Install Passenger packages
RUN apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys 561F9B9CAC40B2F7
RUN apt-get install -y apt-transport-https ca-certificates
RUN sh -c 'echo deb https://oss-binaries.phusionpassenger.com/apt/passenger xenial main > /etc/apt/sources.list.d/passenger.list'
RUN apt-get update -y
RUN apt-get install -y libapache2-mod-passenger

RUN gem2.3 install bundler

# RUN a2enmod passenger
# RUN apache2ctl restart

# Check installation
RUN /usr/bin/passenger-config validate-install
RUN /usr/sbin/passenger-memory-stats

RUN rm -rf $workdir
RUN git clone https://github.com/openstreetmap/openstreetmap-website.git $workdir

# Install app dependencies
WORKDIR $workdir

RUN git checkout master 

RUN bundle update listen && bundle install

ADD config/database.yml $workdir/config/database.yml

ADD config/application.yml $workdir/config/application.yml
# protect sensitive information
# RUN chmod 600 $workdir/config/database.yml $workdir/config/application.yml

# RUN passenger-config about ruby-command # check the version  and path for Ruby
ADD config/production.conf /etc/apache2/sites-available/production.conf

RUN bundle exec rake assets:precompile
RUN bundle exec rake secret RAILS_ENV=production

RUN echo "ServerName $(cat /etc/hostname)" >> /etc/apache2/apache2.conf
RUN mkdir $workdir/html
RUN apache2ctl configtest

CMD bundle exec rails db:migrate && apache2ctl start

