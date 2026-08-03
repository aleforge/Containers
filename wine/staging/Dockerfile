# ---------------------------------------
# Generic Wine image based on Wine staging 
# ---------------------------------------
FROM            ghcr.io/aleforge/base:debian

LABEL       author="AleForge" maintainer="info@aleforge.net"

LABEL       org.opencontainers.image.source="https://github.com/aleforge/containers"
LABEL       org.opencontainers.image.licenses=MIT

## install required packages
RUN             dpkg --add-architecture i386 \
                && apt update -y \
                && apt install -y --no-install-recommends gnupg2 numactl tzdata software-properties-common libntlm0 winbind xvfb xauth python3 libncurses5:i386 libncurses6:i386 libsdl2-2.0-0 libsdl2-2.0-0:i386

RUN             cd /tmp/ \
                && curl -sSL https://github.com/gorcon/rcon-cli/releases/download/v0.10.3/rcon-0.10.3-amd64_linux.tar.gz > rcon.tar.gz \
                && tar xvf rcon.tar.gz \
                && mv rcon-0.10.3-amd64_linux/rcon /usr/local/bin/

# Install wine and with recommends
RUN             mkdir -pm755 /etc/apt/keyrings
RUN             wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
RUN             wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/debian/dists/bookworm/winehq-bookworm.sources
# WineHQ sometimes publishes amd64 before i386; install the newest version available for both arches
RUN             apt update \
                && apt-cache madison wine-staging-i386 | awk '{print $3}' | sort -u > /tmp/wine-i386.vers \
                && apt-cache madison wine-staging-amd64 | awk '{print $3}' | sort -u > /tmp/wine-amd64.vers \
                && VER="$(comm -12 /tmp/wine-i386.vers /tmp/wine-amd64.vers | sort -V | tail -1)" \
                && test -n "$VER" \
                && echo "Installing wine-staging $VER" \
                && apt install --install-recommends \
                    "wine-staging-i386=$VER" \
                    "wine-staging-amd64=$VER" \
                    "wine-staging=$VER" \
                    "winehq-staging=$VER" \
                    cabextract wine-binfmt -y

# Set up Winetricks
RUN	            wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
                && chmod +x /usr/sbin/winetricks

ENV             HOME=/home/container
ENV             WINEPREFIX=/home/container/.wine
ENV             WINEDEBUG=-all
ENV             WINEDLLOVERRIDES="mscoree,mshtml="
ENV             DISPLAY=:0
ENV             DISPLAY_WIDTH=1024
ENV             DISPLAY_HEIGHT=768
ENV             DISPLAY_DEPTH=16
ENV             AUTO_UPDATE=1
ENV             XVFB=1

COPY            ./../entrypoint.sh /entrypoint.sh
CMD             [ "/bin/bash", "/entrypoint.sh" ]
