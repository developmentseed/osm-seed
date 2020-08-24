FROM ubuntu:18.04
RUN apt-get -y update && apt-get -y install software-properties-common
RUN add-apt-repository multiverse && apt update && apt -y install libboost-all-dev \
 git-core \
 tar \
 unzip \
 wget \
 bzip2 \
 build-essential \
 autoconf \
 libtool \
 libxml2-dev \
 libgeos-dev \
 libgeos++-dev \
 libpq-dev \
 libbz2-dev \
 libproj-dev \
 munin-node \
 munin \
 libprotobuf-c0-dev \
 protobuf-c-compiler \
 libfreetype6-dev \
 libtiff5-dev \
 libicu-dev \
 libgdal-dev \
 libcairo-dev \
 libcairomm-1.0-dev \
 apache2 \
 apache2-dev \
 libagg-dev \
 liblua5.2-dev \
 ttf-unifont \
 lua5.1 \
 liblua5.1-dev \
 libgeotiff-epsg \
 python3-pip
# mapnik
RUN apt-get -y install autoconf \
 apache2-dev \
 libtool \
 libxml2-dev \
 libbz2-dev \
 libgeos-dev \
 libgeos++-dev \
 libproj-dev \ 
 gdal-bin \
 libmapnik-dev \
 mapnik-utils \
 python-mapnik \
 python3-psycopg2
RUN pip3 install pyyaml psycopg2 requests
RUN python -c "import mapnik"
ENV workdir /src
WORKDIR $workdir
#mod_tile
RUN git clone -b switch2osm git://github.com/SomeoneElseOSM/mod_tile.git && \
 cd mod_tile && \
 ./autogen.sh && \
 ./configure && \
 make && \
 make install && \
 make \
 install-mod_tile && \
 ldconfig
### osm-carto
RUN cd $workdir
RUN apt-get -y install nodejs-dev \
 node-gyp \
 libssl1.0-dev 
RUN git clone git://github.com/gravitystorm/openstreetmap-carto.git && \
  cd openstreetmap-carto && \
  apt -y install npm nodejs && \
  npm install -g carto && \
  sed -i '/dbname: "gis"/d' project.mml && \
  carto project.mml > mapnik.xml
# fonts
RUN apt-get -y install fonts-noto-cjk \
 fonts-noto-hinted \
 fonts-noto-unhinted \
 ttf-unifont
# configure renderd
COPY ./config/renderd.conf /usr/local/etc/renderd.conf
# configuring apache2
RUN mkdir -p /var/lib/mod_tile && mkdir -p /var/run/renderd
COPY ./config/mod_tile.conf /etc/apache2/conf-available/mod_tile.conf
RUN a2enconf mod_tile
COPY ./config/apache2.conf /etc/apache2/sites-available/000-default.conf
RUN cd $workdir
COPY ./start.sh .
RUN chmod a+x $workdir/start.sh
CMD ./start.sh