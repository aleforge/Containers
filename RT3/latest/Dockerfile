# I N F R A
# Dockerfile with SteamRT3 
FROM        registry.gitlab.steamos.cloud/steamrt/sniper/platform:latest-container-runtime-depot

LABEL       author="AleForge" maintainer="support@mail.aleforge.net"
LABEL       org.opencontainers.image.source="https://github.com/aleforge/containers"
LABEL       org.opencontainers.image.licenses=MIT

# Prep OS
RUN         mkdir -p /etc/sudoers.d && echo "%sudo ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/flatdeb && chmod 0440 /etc/sudoers.d/flatdeb
ENV         DEBIAN_FRONTEND=noninteractive
RUN         apt update && apt install -y iproute2 && apt-get clean
USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

# To-Do: If CS2 requires Wine, the following lines will need to be uncommented
# RUN         apt update
# RUN         apt install -y wine wine64 libwine && apt clean

# EP
COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         [ "/bin/bash", "/entrypoint.sh" ]
