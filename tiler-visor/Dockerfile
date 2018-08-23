FROM nginx:1.15.2-alpine
RUN apk add --no-cache  git bash
RUN rm /usr/share/nginx/html/*
RUN git clone https://github.com/go-spatial/tegola-web-demo.git /usr/share/nginx/html
COPY ./start.sh ./start.sh
RUN mkdir -p /usr/share/nginx/html/capabilities
COPY ./config/osm.json /usr/share/nginx/html/capabilities/osm.json
CMD ./start.sh