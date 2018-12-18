FROM golang:1.11.0-alpine3.8 AS build
RUN apk update
RUN apk add musl-dev=1.1.19-r10 \
    gcc=6.4.0-r9 \
    bash \
    git \
    postgresql \
    postgresql-contrib

RUN mkdir -p /go/src/github.com/go-spatial/tegola
RUN git clone https://github.com/go-spatial/tegola.git /go/src/github.com/go-spatial/tegola
RUN cd /go/src/github.com/go-spatial/tegola && git checkout v0.8.1
RUN cd /go/src/github.com/go-spatial/tegola/cmd/tegola \
	&& go build -gcflags "-N -l" -o /opt/tegola \ 
	&& chmod a+x /opt/tegola
RUN ln -s /opt/tegola /usr/bin/tegola
# Volumen
ENV CACHEDATA /mnt/data
RUN mkdir -p "$CACHEDATA" && chmod 777 "$CACHEDATA"
VOLUME /mnt/data
COPY ./config/config.toml  /opt/tegola_config/config.toml
COPY ./start.sh ./start.sh
CMD ./start.sh