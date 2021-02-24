FROM python:3.7-alpine

RUN apk update && \
    apk add git

ENV workdir /usr/src/app

RUN git clone https://github.com/hotosm/tasking-manager.git $workdir
# Commits on Oct 23, 2020
RUN cd $workdir && git checkout 951039f86938b9cc9d8b6986c4e5f3423a78e4d3
WORKDIR $workdir

# Setup backend dependencies
RUN apk update && \
    apk add \
        gcc \
        g++ \
        make \
        musl-dev \
        libffi-dev \
        python3-dev \
        postgresql-dev \
        geos-dev \
        proj-util \
        proj-dev

RUN pip install --prefix=/install --no-warn-script-location -r requirements.txt

## INITIALIZATION

EXPOSE 5000
CMD ["gunicorn", "-b", "0.0.0.0:5000", "--worker-class", "gevent", "--workers", "3", \
    "--threads", "3", "--timeout", "179", "manage:application", "&"]
