FROM        	ubuntu:24.04

LABEL       author="AleForge" maintainer="info@aleforge.net"

LABEL       org.opencontainers.image.source="https://github.com/aleforge/containers"
LABEL       org.opencontainers.image.licenses=MIT

## install required packages
ARG             DEBIAN_FRONTEND=noninteractive
RUN             dpkg --add-architecture i386
RUN             apt update
RUN             apt -y upgrade
RUN             apt install -y --no-install-recommends \
                    apt-transport-https \
                    binutils \
                    ca-certificates \
                    cabextract \
                    curl \
                    ffmpeg \
                    g++ \
                    gcc \
                    gdb \
                    git \
                    gnupg2 \
					gnutls-bin \
                    icu-devtools \
                    iproute2 \
                    locales \
                    net-tools \
                    netcat-openbsd \
                    procps \
                    python3 \
                    rapidjson-dev \
                    software-properties-common \
                    sqlite3 \
                    tar \
                    telnet \
                    tini \
                    tzdata \
                    unzip \
                    wget \
                    winbind \
                    xauth \
                    xvfb \
                    xz-utils \
                    zip \
                    libatomic1 \
                    libc++-dev \
                    libc6 \
                    libduktape207 \
                    libevent-dev \
                    libfluidsynth3 \
                    libfontconfig \
                    libgcc1 \
                    libicu74 \
                    liblua5.4-0 \
                    liblzo2-2 \
                    libmariadbclient-dev-compat \
                    libncurses6:i386 \
                    libntlm0 \
                    libprotobuf32 \
                    libsdl1.2debian \
                    libsdl2-2.0-0 \
                    libsdl2-2.0-0:i386 \
                    libsqlite3-dev \
                    libstdc++6 \
                    libunwind8 \
                    libz-dev \
                    libzip4

RUN 			apt-get clean \
				&& rm -rf /var/lib/apt/lists/*

# Install wine and with recommends
RUN             mkdir -pm755 /etc/apt/keyrings
RUN             wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN             wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
RUN             apt update
RUN             apt install --install-recommends winehq-staging winbind cabextract -y

# Install Powershell
RUN 			wget -q https://packages.microsoft.com/config/ubuntu/24.04/packages-microsoft-prod.deb
RUN 			dpkg -i packages-microsoft-prod.deb
RUN 			rm packages-microsoft-prod.deb
RUN 			apt update
RUN 			apt install -y powershell

# Set up Winetricks
RUN	            wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks
RUN             chmod +x /usr/sbin/winetricks

## install rcon
RUN             cd /tmp/ \
                && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
                && tar xvf rcon.tar.gz \
                && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/

# Setup ENVs
ENV             HOME=/home/container
ENV             WINEPREFIX=/home/container/.wine
ENV             WINEDLLOVERRIDES="mscoree,mshtml="
ENV             DISPLAY=:0
ENV             DISPLAY_WIDTH=1024
ENV             DISPLAY_HEIGHT=768
ENV             DISPLAY_DEPTH=16

# Set the locale
RUN         	sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
            	locale-gen
ENV        		LANG=en_US.UTF-8
ENV         	LANGUAGE=en_US:en
ENV         	LC_ALL=en_US.UTF-8

RUN             bash -c 'echo "vm.max_map_count = 16777216" > /etc/sysctl.d/20-max_map_count.conf'

## Setup user and working directory
RUN             useradd -m -d /home/container -s /bin/bash container
USER            container
ENV             USER=container HOME=/home/container
WORKDIR         /home/container

# Sets the default stop signal as wings can (currently) only send a kill or generic stop
STOPSIGNAL SIGINT

COPY            --chown=container:container ../entrypoint.sh /entrypoint.sh
RUN             chmod +x /entrypoint.sh
ENTRYPOINT      ["/usr/bin/tini", "-g", "--"]
CMD             ["/entrypoint.sh"]