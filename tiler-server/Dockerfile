FROM golang:1.9.2-alpine3.7 AS build
RUN apk update
RUN apk add --no-cache musl-dev linux-headers g++
RUN apk add gcc=6.4.0-r5
RUN apk add g++
RUN apk add git
RUN apk add bash
RUN apk add postgresql
RUN apk add postgresql-contrib

# # Set up source for compilation
RUN git clone -b v0.6.4 https://github.com/go-spatial/tegola.git /opt/tegola_src
RUN rm -rf /opt/tegola_src/src
RUN mkdir -p /opt/tegola_src/src/github.com/go-spatial
RUN ln -s /opt/tegola_src /opt/tegola_src/src/github.com/go-spatial/tegola

# Build binary
WORKDIR /opt/tegola_src/cmd/tegola
ENV GOPATH /opt/tegola_src
RUN go build -v -gcflags "-N -l" -o /opt/tegola
RUN chmod a+x /opt/tegola
RUN ln -s /opt/tegola /usr/bin/tegola

COPY ./config/config.toml  /opt/tegola_config/config.toml
COPY ./start.sh .
CMD ./start.sh
