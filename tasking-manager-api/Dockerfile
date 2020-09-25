
FROM python:3.7-alpine

RUN apk update && \
    apk add git

ENV workdir /usr/src/app

RUN echo 'bust cache'
RUN git clone https://github.com/OpenHistoricalMap/tasking-manager.git $workdir
WORKDIR $workdir
RUN git checkout d94ea226e2142da7e2b4b33755ab12ce41797458

# Setup backend dependencies
RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev libffi-dev geos-dev proj-util proj-dev make
RUN pip install --no-cache-dir -r requirements.txt

## INITIALIZATION

EXPOSE 5000
CMD ["gunicorn", "-b", "0.0.0.0:5000", "--worker-class", "gevent", "--workers", "3", \
	"--threads", "3", "--timeout", "179", "manage:application", "&"]