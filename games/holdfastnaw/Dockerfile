FROM  ubuntu:24.04

LABEL author="AleForge Support" maintainer="support@mail.aleforge.net"
LABEL org.opencontainers.image.source="https://github.com/aleforge/containers/"
LABEL org.opencontainers.image.description="A Docker image to run Holdfast NAW on AleForge Panel (https://panel.aleforge.net)" 

ENV   DEBIAN_FRONTEND noninteractive

RUN               dpkg --add-architecture i386
RUN               apt update
RUN               apt -y upgrade
RUN               apt install -y --no-install-recommends \
                        gcc \
                        g++ \
                        libgcc1 \
                        lib32gcc1 \
                        gdb \
                        libc6 \
                        libstdc++6 \
                        git \
                        wget \
                        curl \
                        tar \
                        zip \
                        unzip \
                        binutils \
                        xz-utils \
                        liblzo2-2 \
                        bzip2 \
                        zlib1g \
                        iproute2 \
                        net-tools \
                        netcat \
                        telnet \
                        libatomic1 \
                        libsdl1.2debian \
                        libsdl2-2.0-0 \
                        libfontconfig \
                        libicu60 \
                        libiculx60 \
                        icu-devtools \
                        libunwind8 \
                        libssl1.0.0 \
                        libssl1.0-dev \
                        sqlite3 \
                        libsqlite3-dev \
                        libmariadbclient-dev \
                        libduktape202 \
                        libzip4 \
                        locales \
                        ffmpeg \
                        apt-transport-https \
                        tini 

## Steamclient.so Link
RUN ln -s "/home/container/steamcmd/linux64/steamclient.so" "/usr/lib/x86_64-linux-gnu/steamclient.so" 

## configure locale
RUN   update-locale lang=en_US.UTF-8 \
 &&   dpkg-reconfigure --frontend noninteractive locales

# Setup user and working directory
RUN         useradd -m -d /home/container -s /bin/bash container
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL  SIGINT

COPY        --chown=container:container ./../entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT  ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]