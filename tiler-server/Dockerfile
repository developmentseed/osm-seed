FROM golang:1.9.2-alpine3.7 AS build
RUN apk update
RUN apk add musl-dev \
    linux-headers \
    g++ \
    gcc=6.4.0-r5 \
    g++ \
    git \
    bash \
    postgresql \
    postgresql-contrib

# Set up source for compilation
ENV GOROOT /usr/local/go
RUN git clone -b v0.8.1 https://github.com/go-spatial/tegola.git /opt/tegola_src
RUN rm -rf /opt/tegola_src/src
RUN mkdir -p /opt/tegola_src/src/github.com/go-spatial
RUN ln -s /opt/tegola_src /opt/tegola_src/src/github.com/go-spatial/tegola
RUN git clone -b v1.10.0 https://github.com/theckman/goconstraint.git /opt/tegola_src/src/github.com/theckman/goconstraint

# Volumen
ENV CACHEDATA /mnt/data
RUN mkdir -p "$CACHEDATA" && chmod 777 "$CACHEDATA"
VOLUME /mnt/data

# Build binary
WORKDIR /opt/tegola_src/cmd/tegola
ENV GOPATH /opt/tegola_src
RUN go build -v -gcflags "-N -l" -o /opt/tegola
RUN chmod a+x /opt/tegola
RUN ln -s /opt/tegola /usr/bin/tegola

COPY ./config/config.toml  /opt/tegola_config/config.toml
COPY ./start.sh ./start.sh
CMD ./start.sh