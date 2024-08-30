FROM debian:bookworm-slim
ENV workdir /mnt/data
WORKDIR $workdir

# Installs osmosis v0.48.3 & osmium-tool v1.15.0
RUN set -ex \
     && apt-get update \
     && DEBIAN_FRONTEND=noninteractive apt-get install \
     -y --no-install-recommends \
        "osmosis" \
        "osmium-tool" \
        # Cloud provider CLIs
        "awscli" \
        "gsutil" \
        "azure-cli" \
        # Other useful packages
        "rsync" \
        "pyosmium" \
        "tmux" \
        "zsh" \
     && rm -rf /var/lib/apt/lists/*
