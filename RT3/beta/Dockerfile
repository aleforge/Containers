# I N F R A
# Dockerfile with SteamRT3 
FROM        registry.gitlab.steamos.cloud/steamrt/sniper/platform:latest-container-runtime-public-beta

LABEL       author="AleForge" maintainer="support@mail.aleforge.net"
LABEL       org.opencontainers.image.source="https://github.com/aleforge/containers"
LABEL       org.opencontainers.image.licenses=MIT

## add container user
RUN   useradd -m -d /home/container -s /bin/bash container

## update base packages
RUN   apt update \
        &&   apt upgrade -y

## install dependencies
RUN   apt install -y iproute2 && apt-get clean

# Prep OS
RUN         mkdir -p /etc/sudoers.d && echo "%sudo ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/flatdeb && chmod 0440 /etc/sudoers.d/flatdeb
ENV         DEBIAN_FRONTEND=noninteractive


## configure locale
RUN   update-locale lang=en_US.UTF-8 \
        &&   dpkg-reconfigure --frontend noninteractive locales

# To-Do: If CS2 requires Wine, the following lines will need to be uncommented
# RUN         apt update
# RUN         apt install -y wine wine64 libwine && apt clean

WORKDIR /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
