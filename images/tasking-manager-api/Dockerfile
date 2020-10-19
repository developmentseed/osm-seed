FROM python:3.7-alpine

RUN apk update && \
    apk add git

ENV workdir /usr/src/app

RUN git clone https://github.com/hotosm/tasking-manager.git $workdir
WORKDIR $workdir

# Setup backend dependencies
RUN apk update && apk add postgresql-dev gcc python3-dev musl-dev libffi-dev geos-dev proj-util proj-dev make
RUN pip install --no-cache-dir -r requirements.txt

## INITIALIZATION

EXPOSE 5000
CMD ["gunicorn", "-b", "0.0.0.0:5000", "--worker-class", "gevent", "--workers", "3", \
	"--threads", "3", "--timeout", "179", "manage:application", "&"]