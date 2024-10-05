FROM developmentseed/osmseed-osm-processor:0.1.0-n795.h1c8d32f

# Install Nginx
RUN apt-get update && \
    apt-get install -y nginx && \
    rm -rf /var/lib/apt/lists/*
    
RUN pip3 install boto3
COPY ./*.sh /
COPY monitoring.py /
WORKDIR /mnt/data
CMD /start.sh
