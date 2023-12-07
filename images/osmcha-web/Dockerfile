FROM node:16-slim as builder

ENV DEBIAN_FRONTEND noninteractive

ARG BUILD_ENV=prod

RUN apt-get update && apt-get install -y git

RUN mkdir /app
WORKDIR /app
RUN git clone https://github.com/sunu/osmcha-frontend.git /app
RUN yarn install

ENV REACT_APP_PRODUCTION_API_URL /api/v1
RUN yarn build:${BUILD_ENV}

FROM nginx:alpine
# COPY config/nginx.conf /etc/nginx/
# COPY config/mime.types /etc/nginx/ 
# RUN nginx -t
COPY --from=builder /app/build /assets
