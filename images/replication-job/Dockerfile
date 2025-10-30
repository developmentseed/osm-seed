FROM andygol/osmosis:0.49.2
USER root

RUN apk update && apk add --no-cache python3 py3-pip procps curl bash postgresql-client py3-crcmod

RUN python3 -m venv /opt/venv \
    && /opt/venv/bin/pip install --no-cache-dir \
        boto3 \
        awscli 
ENV PATH="/opt/venv/bin:$PATH"

COPY ./*.sh /
COPY monitoring.py /

WORKDIR /mnt/data

ENTRYPOINT ["/bin/bash","-lc"]
CMD /start.sh
