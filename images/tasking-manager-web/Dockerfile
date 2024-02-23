
FROM node:12 AS builder
RUN sed -i s/deb.debian.org/archive.debian.org/g /etc/apt/sources.list
RUN sed -i 's|security.debian.org|archive.debian.org|g' /etc/apt/sources.list 
RUN sed -i '/stretch-updates/d' /etc/apt/sources.list 
RUN apt-get update && apt-get -y install apt-transport-https
RUN apt-get update && \
    apt-get install -y git
WORKDIR /app
ENV GITSHA=951039f86938b9cc9d8b6986c4e5f3423a78e4d3
RUN git clone https://github.com/hotosm/tasking-manager.git /app
WORKDIR /app/frontend
RUN git checkout $GITSHA
RUN npm install && npm run build

FROM nginx:latest
COPY --from=builder /app/frontend/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]