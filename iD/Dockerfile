FROM ubuntu:16.04
ENV workdir /app
RUN apt-get update -y
RUN apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get install -y nodejs
RUN apt-get install -y wget python-pip software-properties-common python-software-properties git 
RUN pip install awscli
RUN git clone --depth=1 https://github.com/openstreetmap/iD.git $workdir
WORKDIR $workdir
RUN npm install
RUN npm run all
ADD start.sh $workdir/start.sh
ADD info.js $workdir/info.js
CMD ./start.sh