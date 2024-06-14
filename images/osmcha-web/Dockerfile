FROM node:16-slim as builder
ENV DEBIAN_FRONTEND noninteractive
ENV BUILD_ENV=prod
ENV REACT_APP_PRODUCTION_API_URL=/api/v1
RUN apt-get update && apt-get install -y git \
    && rm -rf /var/lib/apt/lists/*
RUN mkdir /app
WORKDIR /app
ARG GIT_TAG=master
RUN git clone --branch $GIT_TAG https://github.com/osmus/osmcha-frontend.git /app
RUN yarn install
COPY start.sh .
CMD [ "/app/start.sh" ]
