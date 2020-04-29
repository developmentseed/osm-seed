FROM golang:1.14.1-alpine3.11 AS build
ENV VERSION="v0.8.1"

RUN apk update
RUN apk add musl-dev=1.1.24-r2 \
	gcc=9.2.0-r4 \
    bash \
    git \
    postgresql \
    postgresql-contrib

# Set up source for compilation
RUN git clone https://github.com/go-spatial/tegola.git  /go/src/github.com/go-spatial/tegola

# Build binary
RUN cd /go/src/github.com/go-spatial/tegola/ \
	&& go build -v -ldflags "-w -X github.com/go-spatial/tegola/cmd/tegola/cmd.Version=${VERSION}" -gcflags "-N -l" -o /opt/tegola \ 
	&& chmod a+x /opt/tegola

# Create minimal deployment image, just alpine & the binary
FROM alpine:3.11

RUN apk update \
	&& apk add ca-certificates \
	&& rm -rf /var/cache/apk/*

COPY --from=build /opt/tegola /opt/
WORKDIR /opt
RUN ln -s /opt/tegola /usr/bin/tegola

VOLUME /mnt/data
COPY ./config/config.toml /opt/tegola_config/config.toml
COPY ./start.sh ./start.sh
CMD ./start.sh