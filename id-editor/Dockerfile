FROM nginx:stable
ENV workdir /app
RUN apt-get update
RUN apt-get install -y wget gnupg
RUN apt-get install -y curl software-properties-common git
RUN curl -sL https://deb.nodesource.com/setup_10.x | bash -
RUN apt-get update && apt-get install -y nodejs
RUN git clone --depth=1 -b ohm https://github.com/OpenHistoricalMap/iD.git $workdir
WORKDIR $workdir
RUN npm install
ADD start.sh $workdir/start.sh
ADD info.js $workdir/info.js
CMD ./start.sh