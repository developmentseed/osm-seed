FROM developmentseed/osmseed-osm-processor:v2

RUN pip3 install boto3
COPY ./start.sh /
COPY monitoring.py /
WORKDIR /mnt/data
CMD /start.sh
