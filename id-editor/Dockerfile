FROM nginx:stable
ENV workdir /app
RUN apt-get update -y
RUN apt-get update && apt-get install -my wget gnupg
RUN apt-get install -y curl software-properties-common git
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs
RUN git clone --depth=1 https://github.com/developmentseed/iD.git $workdir
WORKDIR $workdir
RUN npm install
ADD start.sh $workdir/start.sh
ADD info.js $workdir/info.js
CMD ./start.sh