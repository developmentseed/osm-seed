FROM developmentseed/osmseed-osm-processor:v2

# Install Nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*
    
RUN pip3 install boto3
COPY ./*.sh /
COPY monitoring.py /
WORKDIR /mnt/data
CMD /start.sh
