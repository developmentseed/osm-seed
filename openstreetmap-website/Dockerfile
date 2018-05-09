FROM ubuntu:16.04

RUN apt-get update

RUN apt-get install -y ruby2.3 libruby2.3 ruby2.3-dev \
                     libmagickwand-dev libxml2-dev libxslt1-dev nodejs \
                     apache2 apache2-dev build-essential git-core \
                     postgresql postgresql-contrib libpq-dev postgresql-server-dev-all \
                     libsasl2-dev imagemagick libffi-dev

RUN gem2.3 install bundler

RUN mkdir -p app

WORKDIR /app

RUN git clone https://github.com/openstreetmap/openstreetmap-website.git

WORKDIR /app/openstreetmap-website

RUN git checkout master # we will want to checkout specific commits / versions

RUN bundle install

ADD config/database.yml /app/openstreetmap-website/config/database.yml

ADD config/application.yml /app/openstreetmap-website/config/application.yml

EXPOSE 3000

CMD bundle exec rails db:migrate && bundle exec rails server -p 3000 -b '0.0.0.0'
