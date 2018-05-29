FROM node:8
ENV workdir /app
RUN apt-get update
RUN apt-get install -y git 
RUN pip install awscli
RUN git clone --depth=1 https://github.com/openstreetmap/iD.git $workdir
WORKDIR $workdir
RUN npm install
RUN npm run all
CMD ./script.sh