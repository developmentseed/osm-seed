FROM nginx:latest
RUN apt-get update && \
    apt-get install -y nodejs npm && \
    rm -rf /var/lib/apt/lists/*
WORKDIR /usr/share/nginx/html/server/
COPY server/package.json ./
RUN npm install
COPY server/server.js ./
COPY index.html /usr/share/nginx/html/
CMD ["sh", "-c", "nginx -g 'daemon off;' & node server.js"]
