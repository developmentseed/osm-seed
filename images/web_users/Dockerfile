FROM python:3
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
RUN apt-get update \ 
    && apt-get install -y postgresql-client

WORKDIR /app
COPY app/requirements.txt /app/
RUN pip install -r requirements.txt
RUN python -m pip install django[argon2]
COPY app/ /app/
EXPOSE 8000/tcp
CMD ./start.sh
