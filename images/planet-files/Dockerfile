FROM nginx
RUN apt-get update && apt-get install -y nodejs npm
COPY server/package.json /usr/share/nginx/html/server/
RUN cd /usr/share/nginx/html/server && npm install
COPY server/server.js /usr/share/nginx/html/server/
COPY index.html /usr/share/nginx/html/
CMD ["sh", "-c", "nginx -g 'daemon off;' & cd /usr/share/nginx/html/server/ && node server.js"]
