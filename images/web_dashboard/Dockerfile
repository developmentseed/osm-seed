FROM postgres:12
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

RUN apt-get update -qq
RUN apt-get -y install \
    build-essential libpq-dev \
    python3-dev python3-pip curl sudo

WORKDIR /app
COPY app/requirements.txt /app/
RUN pip install -r requirements.txt
COPY app/ /app/
# COPY start.sh /app/

# sed -n "x p" dump.sql

# RUN echo "echo \"==========Start App==========\"" >> /usr/local/bin/docker-entrypoint.sh
# RUN echo "./app/start.sh" >> /usr/local/bin/docker-entrypoint.sh

# COPY start.sh /usr/local/bin/
EXPOSE 5433
EXPOSE 8000

ENTRYPOINT ["sh","/app/start.sh"]
# CMD /app/start.sh
