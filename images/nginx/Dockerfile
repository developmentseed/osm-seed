FROM nginx
RUN apt-get update
RUN apt-get -y install openssl
RUN openssl req -x509 -nodes -newkey rsa:2048 -keyout key.pem -out cert.pem -sha256 -days 365 \
    -subj "/C=GB/ST=London/L=London/O=Alros/OU=IT Department/CN=localhost"
RUN mkdir -p /root/ssl/
RUN cp key.pem /root/ssl/key.pem
RUN cp cert.pem /root/ssl/cert.pem
COPY nginx.conf /etc/nginx/conf.d/default.conf
