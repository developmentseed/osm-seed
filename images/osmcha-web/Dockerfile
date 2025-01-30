FROM node:22-alpine as builder

ENV DEBIAN_FRONTEND noninteractive

ARG GITSHA=3cd987bd2ed02bbb60b121ecad0bb556a115aca1
ARG BUILD_ENV=prod

WORKDIR /app

## Clone osmcha repo
RUN apk add --no-cache git \
    && git clone https://github.com/OSMCha/osmcha-frontend.git /app \
    && cd /app \
    && git checkout $GITSHA

RUN yarn set version stable
RUN yarn install

ENV REACT_APP_PRODUCTION_API_URL /api/v1
ENV NODE_OPTIONS --openssl-legacy-provider

RUN yarn run build:${BUILD_ENV}

FROM nginx:alpine

COPY --from=builder /app/build /srv/www

COPY nginx.conf /etc/nginx/templates/default.conf.template
