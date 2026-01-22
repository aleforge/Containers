# ---------------------------------------
# Generic Wine image based on Wine stable 
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
RUN             apt update
RUN             apt install --install-recommends wine-stable-i386 -y && \
                apt install --install-recommends wine-stable-amd64 -y && \
                apt install --install-recommends wine-stable -y && \
                apt install --install-recommends winehq-stable -y && \
                apt install --install-recommends cabextract wine-binfmt -y

# Ensure wine64 is available in PATH
RUN             ln -sf /opt/wine-stable/bin/wine64 /usr/local/bin/wine64 || \
                ln -sf /usr/lib/wine/wine64 /usr/local/bin/wine64 || \
                ln -sf /usr/bin/wine64 /usr/local/bin/wine64 || true

# Set up Winetricks
RUN	            wget -q -O /usr/sbin/winetricks https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks \
                && chmod +x /usr/sbin/winetricks

ENV             PATH="/opt/wine-stable/bin:${PATH}"
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