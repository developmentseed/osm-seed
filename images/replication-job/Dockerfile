FROM developmentseed/osmseed-osm-processor:0.1.0-n802.h0d9f574

RUN apt-get update && \
    apt-get install -y \
        nginx \
        python3-pip \
        python3-venv \
        procps \
        curl && \
    rm -rf /var/lib/apt/lists/*

RUN python3 -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"
RUN pip install --no-cache-dir boto3

COPY ./*.sh /
COPY monitoring.py /

WORKDIR /mnt/data

CMD /start.sh
