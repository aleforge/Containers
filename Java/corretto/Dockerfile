FROM        --platform=$TARGETOS/$TARGETARCH debian:13-slim

ARG         JAVA_VERSION=25

LABEL       author="AleForge Support" maintainer="support@mail.aleforge.net"
LABEL       org.opencontainers.image.source="https://github.com/aleforge/containers/"
LABEL       org.opencontainers.image.description="A Docker image to run Amazon Corretto JDK ${JAVA_VERSION} on AleForge Panel (https://panel.aleforge.net)"

ENV         DEBIAN_FRONTEND=noninteractive

RUN         apt-get update \
            && apt-get install -y --no-install-recommends ca-certificates curl gnupg \
            && mkdir -p /usr/share/keyrings \
            && curl -fsSL https://apt.corretto.aws/corretto.key | gpg --dearmor -o /usr/share/keyrings/corretto-keyring.gpg \
            && echo "deb [signed-by=/usr/share/keyrings/corretto-keyring.gpg] https://apt.corretto.aws stable main" > /etc/apt/sources.list.d/corretto.list \
            && apt-get update \
            && if [ "$JAVA_VERSION" = "8" ]; then pkg=java-1.8.0-amazon-corretto-jdk; else pkg="java-${JAVA_VERSION}-amazon-corretto-jdk"; fi \
            && apt-get install -y --no-install-recommends \
                "$pkg" \
                curl \
                lsof \
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
            && ln -sfn "$(dirname "$(dirname "$(readlink -f "$(command -v java)")")")" /usr/lib/jvm/java-current \
            && apt-get clean \
            && rm -rf /var/lib/apt/lists/* \
            && rm -f /usr/bin/dd /usr/bin/fallocate /usr/bin/truncate /usr/bin/xfs_mkfile

ENV         JAVA_HOME=/usr/lib/jvm/java-current
ENV         PATH=/usr/lib/jvm/java-current/bin:$PATH

COPY        ../distrust-emudhra.sh /tmp/distrust-emudhra.sh
RUN         chmod +x /tmp/distrust-emudhra.sh \
            && /tmp/distrust-emudhra.sh \
            && rm /tmp/distrust-emudhra.sh

## Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ../entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT  ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
