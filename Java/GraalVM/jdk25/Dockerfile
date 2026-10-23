FROM        --platform=$TARGETOS/$TARGETARCH debian:13-slim

LABEL       author="AleForge Support" maintainer="support@mail.aleforge.net"
LABEL       org.opencontainers.image.source="https://github.com/aleforge/containers/"
LABEL       org.opencontainers.image.description="A Docker image to run GraalVM Community JDK 25 on AleForge Panel (https://panel.aleforge.net)"

ENV         DEBIAN_FRONTEND=noninteractive
ENV         LANG=en_US.UTF-8
ENV         LANGUAGE=en_US:en
ENV         LC_ALL=en_US.UTF-8

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
                libstdc++6 \
                tini \
                zip \
                unzip \
                jq \
                locales \
            && apt-get upgrade -y \
            && sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen \
            && locale-gen \
            && apt-get clean \
            && rm -rf /var/lib/apt/lists/* \
            && rm -f /usr/bin/dd /usr/bin/fallocate /usr/bin/truncate /usr/bin/xfs_mkfile

# GraalVM Community 25 Innovation 4, JDK 25.0.4.1.1.
ARG         TARGETPLATFORM
RUN         arch=x64; \
            case "${TARGETPLATFORM:-linux/amd64}" in \
                linux/arm64|linux/aarch64) arch=aarch64 ;; \
            esac; \
            curl --retry 3 -LfsSo /tmp/graalvm.tar.gz "https://github.com/graalvm/graalvm-ce-builds/releases/download/graal-25.4.4.1.1/graalvm-community-jdk-25i4-25.0.4.1.1_linux-${arch}_bin.tar.gz"; \
            mkdir -p /opt/java/graalvm; \
            tar -xzf /tmp/graalvm.tar.gz --strip-components=1 -C /opt/java/graalvm; \
            rm /tmp/graalvm.tar.gz

ENV         JAVA_HOME=/opt/java/graalvm
ENV         PATH=/opt/java/graalvm/bin:$PATH

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
