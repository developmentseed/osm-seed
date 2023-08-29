FROM ruby:2.4
RUN git clone https://github.com/zerebubuth/openstreetmap-changeset-replication.git /app
WORKDIR /app
RUN apt-get install -y curl unzip
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install
# TODO: Install Google Cloud Platform (GCP) and Azure CLI for better data management
RUN gem install pg -v 0.21.0 
RUN gem install libxml-ruby -v 3.1.0
COPY start.sh .
RUN chmod +x replicate_changesets.rb
CMD /app/start.sh
