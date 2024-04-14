FROM ruby:3.0-slim

ARG workdir=/usr/src/app
WORKDIR $workdir

RUN apt-get update && apt-get install -y \
    cmake \
    libbz2-dev \
    libexpat1-dev \
    libgd-dev \
    libicu-dev \
    libosmium2-dev \
    libprotozero-dev \
    libsqlite3-dev \
    make \
    zlib1g-dev \
    curl \
    sqlite3 \
    sqlite3-pcre \
    passenger \
    libapache2-mod-passenger \
    libreadline-dev \
    tcl \
    git \
    jq \
    python3-pip \
    wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/taginfo/taginfo-tools.git $workdir/taginfo-tools && \
    cd $workdir/taginfo-tools && \
    git submodule update --init && \
    mkdir build && cd build && \
    cmake .. && make
RUN gem install json rack-contrib puma sinatra:'<3' sinatra-r18n:'5.0.2'

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
    unzip awscliv2.zip && \
    ./aws/install && \
    rm awscliv2.zip

RUN git clone https://github.com/taginfo/taginfo.git $workdir/taginfo && \
    cd $workdir/taginfo && \
    bundle install

# Download and prepare uWSGI
RUN wget http://projects.unbit.it/downloads/uwsgi-latest.tar.gz \
    && tar zxvf uwsgi-latest.tar.gz \
    && rm uwsgi-latest.tar.gz && \
    mv $(ls | grep uwsgi-) uwsgi-dir && \
    cd uwsgi-dir && \
    make PROFILE=nolang && \
    PYTHON=python3 UWSGI_PROFILE_OVERRIDE="ssl=true,rack=true,http=true" make

# # Set non-root user
# RUN groupadd -r taginfo && useradd -m -r -g taginfo taginfo
# RUN chown -R taginfo:taginfo $workdir
# RUN chmod -R 777 $workdir
# USER taginfo

# RUN chown -R www-data: $workdir

WORKDIR $workdir

# Copy configuration files and scripts
COPY config/taginfo-config.json $workdir/
COPY start.sh .

# Expose port and set default command
EXPOSE 80
CMD ["./start.sh"]
