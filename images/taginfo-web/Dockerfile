FROM ruby:3.2-bookworm

RUN apt-get update && apt-get install -y \
    curl \
    sqlite3 \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash taginfo

WORKDIR /usr/src/app

RUN git clone https://github.com/taginfo/taginfo.git taginfo

WORKDIR /usr/src/app/taginfo

RUN echo "gem 'puma'" >> Gemfile && bundle install

RUN mkdir -p /usr/src/app/data /usr/src/app/config

COPY config/taginfo-config.json /usr/src/app/taginfo-config.json

ENV RACK_ENV=production
ENV RACK_HANDLER=puma

EXPOSE 4567

WORKDIR /usr/src/app/taginfo/web
USER taginfo

CMD ["ruby", "taginfo.rb", "-o", "0.0.0.0", "-p", "4567"]
