FROM alpine/git as base
ENV workdir /usr/src/app

RUN git clone https://github.com/OpenHistoricalMap/tasking-manager.git $workdir

FROM tiangolo/node-frontend:10 as build
ENV workdir /usr/src/app

COPY --from=base ${workdir} ${workdir}
WORKDIR ${workdir}/frontend

## SETUP
RUN npm install

# SERVE
ARG TM_APP_API_URL
RUN npm run build

FROM nginx:stable-alpine
ENV workdir /usr/src/app

COPY --from=build $workdir/frontend/build /usr/share/nginx/html
COPY --from=build /nginx.conf /etc/nginx/conf.d/default.conf

CMD ["nginx", "-g", "daemon off;"]