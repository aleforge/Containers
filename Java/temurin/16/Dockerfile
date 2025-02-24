FROM        --platform=$TARGETOS/$TARGETARCH eclipse-temurin:16-jdk-noble

LABEL author="AleForge Support" maintainer="support@mail.aleforge.net"
LABEL org.opencontainers.image.source="https://github.com/aleforge/containers/"
LABEL org.opencontainers.image.description="A Docker image to run GraalVM JDK 16 on AleForge Panel (https://panel.aleforge.net)" 

RUN         apt update -y \
            && apt install -y \
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
				unzip

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./../entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
