FROM        --platform=$TARGETOS/$TARGETARCH eclipse-temurin:24-jdk-noble

LABEL       author="AleForge Support" maintainer="support@mail.aleforge.net"
LABEL       org.opencontainers.image.source="https://github.com/aleforge/containers/"
LABEL       org.opencontainers.image.description="A Docker image to run Temurin JDK 24 on AleForge Panel (https://panel.aleforge.net)"

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt-get update \
            && apt-get install -y --no-install-recommends \
                curl \
                lsof \
                ca-certificates \
                openssl \
                git \
                tar \
                sqlite3 \
                fontconfig \
                tzdata \
                iproute2 \
                libfreetype6 \
                tini \
                zip \
                unzip \
                jq \
            && apt-get upgrade -y \
            && apt-get clean \
            && rm -rf /var/lib/apt/lists/* \
            && rm -f /usr/bin/dd /usr/bin/fallocate /usr/bin/truncate /usr/bin/xfs_mkfile

COPY        ../../distrust-emudhra.sh /tmp/distrust-emudhra.sh
RUN         chmod +x /tmp/distrust-emudhra.sh \
            && /tmp/distrust-emudhra.sh \
            && rm /tmp/distrust-emudhra.sh

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ../../entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT  ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
