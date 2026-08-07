# ---------------------------------------------
# Steam Proton 8 image
# ---------------------------------------------
FROM        debian:bookworm-slim

LABEL author="AleForge Support" maintainer="support@mail.aleforge.net"
LABEL org.opencontainers.image.source="https://github.com/aleforge/containers/"
LABEL org.opencontainers.image.description="A Docker image to run Proton8 and Steamcmd on AleForge Panel (https://panel.aleforge.net)"

ARG         DEBIAN_FRONTEND=noninteractive

## install required packages
RUN         dpkg --add-architecture i386 \
            && apt-get update \
            && apt-get upgrade -y \
            && apt-get install -y --no-install-recommends \
                wget \
                curl \
                ca-certificates \
                iproute2 \
                gnupg2 \
                software-properties-common \
                libntlm0 \
                winbind \
                xvfb \
                xauth \
                libncurses5-dev:i386 \
                libncurses6 \
                dbus \
                libgdiplus \
                lib32gcc-s1 \
                alsa-tools \
                libpulse0 \
                pulseaudio \
                libpulse-dev \
                libasound2 \
                libao-common \
                gnutls-bin \
                gnupg \
                locales \
                numactl \
                cabextract \
                python3 \
                python3-pip \
                python3-setuptools \
                python3-venv \
                pipx \
                tini \
            && apt-get clean \
            && rm -rf /var/lib/apt/lists/*

RUN         useradd -d /home/container -m container

# Download Proton GE 8
RUN         curl -sLOJ "$(curl -s https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/tags/GE-Proton8-32 | grep browser_download_url | cut -d\" -f4 | egrep .tar.gz)" \
            && tar -xzf GE-Proton*.tar.gz -C /usr/local/bin/ --strip-components=1 \
            && rm GE-Proton*.*

# Proton Fix machine-id
RUN         rm -f /etc/machine-id \
            && dbus-uuidgen --ensure=/etc/machine-id \
            && rm -f /var/lib/dbus/machine-id \
            && dbus-uuidgen --ensure

# Setup Protontricks
ENV         PIPX_HOME=/opt/pipx
ENV         PIPX_BIN_DIR=/usr/local/bin
RUN         pipx install protontricks

# Set up Winetricks
RUN         wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
            && chmod +x /usr/sbin/winetricks

## install rcon
RUN         cd /tmp/ \
            && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
            && tar xvf rcon.tar.gz \
            && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/ \
            && rm -rf /tmp/*

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL  SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT  ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
