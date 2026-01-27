FROM ruby:3.2-bookworm

RUN apt-get update && apt-get install -y \
    curl \
    gosu \
    sqlite3 \
    wget \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash taginfo

WORKDIR /usr/src/app
ENV DATA_DIR=/usr/src/app/data
RUN git clone https://github.com/taginfo/taginfo.git taginfo

WORKDIR /usr/src/app/taginfo

RUN echo "gem 'puma'" >> Gemfile && bundle install

RUN mkdir -p $DATA_DIR
RUN chmod -R 777 $DATA_DIR

COPY config/taginfo-config.json /usr/src/app/taginfo-config.json
COPY start.sh /usr/src/app/start.sh
RUN chmod +x /usr/src/app/start.sh

ENV RACK_ENV=production
ENV RACK_HANDLER=puma

EXPOSE 4567

WORKDIR /usr/src/app
CMD ["/usr/src/app/start.sh"]
