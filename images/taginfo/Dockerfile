FROM ruby:2.7
RUN apt-get update
ENV workdir /var/www

RUN apt-get -y install \
    curl \
    sqlite3 \
    sqlite3-pcre \
    ruby-passenger \
    libapache2-mod-passenger \
    git

RUN git clone https://github.com/taginfo/taginfo.git $workdir
WORKDIR $workdir
RUN echo "gem 'thin' " >>Gemfile
RUN gem install bundler
RUN bundle install
# Copy config file
COPY config/taginfo-config.json /var/
EXPOSE 4567
WORKDIR $workdir/web
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "-p", "4567"]
