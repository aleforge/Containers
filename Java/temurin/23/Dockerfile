FROM        --platform=$TARGETOS/$TARGETARCH eclipse-temurin:23-jdk

LABEL author="AleForge Support" maintainer="support@mail.aleforge.net"
LABEL org.opencontainers.image.source="https://github.com/aleforge/containers/"
LABEL org.opencontainers.image.description="A Docker image to run JDK 23 on AleForge Panel (https://panel.aleforge.net)" 

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

RUN         rm -rf /usr/bin/dd \
                && rm -rf /usr/bin/fallocate \
                && rm -rf /usr/bin/truncate \
                && rm -rf /usr/bin/xfs_mkfile


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
