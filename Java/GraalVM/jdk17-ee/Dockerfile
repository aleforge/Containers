FROM        --platform=$TARGETOS/$TARGETARCH debian:13-slim

LABEL       author="AleForge Support" maintainer="support@mail.aleforge.net"
LABEL       org.opencontainers.image.source="https://github.com/aleforge/containers/"
LABEL       org.opencontainers.image.description="A Docker image to run GraalVM Enterprise JDK 17 on AleForge Panel (https://panel.aleforge.net)"

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

# Frozen on GraalVM Enterprise 22.3.4. Classic EE 21.3.20.0.2 has no public URL without an Oracle download token.
RUN         curl --retry 3 -LfsSo /tmp/graalvm.tar.gz "https://f000.backblazeb2.com/file/AleForge-public-Data/java/graalvm/graalvm-ee-java17-linux-amd64-22.3.4.tar.gz" \
            && mkdir -p /opt/java/graalvm \
            && tar -xzf /tmp/graalvm.tar.gz --strip-components=1 -C /opt/java/graalvm \
            && rm /tmp/graalvm.tar.gz

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
