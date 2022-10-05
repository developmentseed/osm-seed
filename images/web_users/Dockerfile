FROM python:3
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
RUN apt-get update \ 
    && apt-get install -y postgresql-client

WORKDIR /app
COPY app/requirements.txt /app/
RUN pip install -r requirements.txt
COPY app/ /app/
CMD ./start.sh
