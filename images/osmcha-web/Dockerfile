FROM node:16-slim as builder

ENV DEBIAN_FRONTEND noninteractive

ARG BUILD_ENV=prod

## Necesary env values to deploy
ENV OSMCHA_URL=https://osmcha-staging.openhistoricalmap.org
ENV OSMCHA_API_URL=www.openhistoricalmap.org
ENV REACT_APP_OSM_URL=https://www.openhistoricalmap.org
ENV REACT_APP_OSM_API=https://www.openhistoricalmap.org/api/0.6
ENV REACT_APP_OVERPASS_BASE=//overpass-api.openhistoricalmap.org/api/interpreter

RUN apt-get update && apt-get install -y git
RUN mkdir /app
WORKDIR /app
RUN git clone https://github.com/sunu/osmcha-frontend.git /app
RUN find /app -type f -exec sed -i 's/www.openstreetmap.org/www.openhistoricalmap.org/g' {} +
RUN yarn install
ENV REACT_APP_PRODUCTION_API_URL /api/v1
RUN sed -i "s|https://osmcha.org|$OSMCHA_URL|g" package.json
RUN yarn build:${BUILD_ENV}

FROM nginx:alpine
COPY --from=builder /app/build /assets
