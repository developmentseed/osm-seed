FROM ruby:3.2-bookworm

RUN apt-get update && apt-get install -y \
    curl \
    sqlite3 \
    wget \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -ms /bin/bash taginfo

WORKDIR /usr/src/app

# Clonar el repo
RUN git clone https://github.com/taginfo/taginfo.git taginfo

WORKDIR /usr/src/app/taginfo

# Añadir puma al Gemfile e instalar dependencias
RUN echo "gem 'puma'" >> Gemfile && bundle install

# Directorios
RUN mkdir -p /usr/src/app/data /usr/src/app/config

# Config
COPY config/taginfo-config.json /usr/src/app/taginfo-config.json
COPY start.sh /usr/src/app/start.sh
RUN chmod +x /usr/src/app/start.sh

ENV RACK_ENV=production
ENV RACK_HANDLER=puma

EXPOSE 4567

WORKDIR /usr/src/app
USER taginfo

CMD ["/usr/src/app/start.sh"]
