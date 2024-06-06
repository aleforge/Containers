# -----------------------------------------------------
# MariaDB Image for Pterodactyl
# -----------------------------------------------------
    FROM        --platform=$TARGETOS/$TARGETARCH mariadb:10.6

    LABEL author="AleForge Support" maintainer="support@mail.aleforge.net"
    LABEL org.opencontainers.image.source="https://github.com/aleforge/containers/"
    LABEL       org.opencontainers.image.licenses=MI
    
    ENV         DEBIAN_FRONTEND noninteractive
    
    RUN         apt update -y \
                && apt install -y netcat \
                && useradd -d /home/container -m container -s /bin/bash
    
    USER        container
    ENV         USER=container HOME=/home/container
    WORKDIR     /home/container
    
    COPY        ../entrypoint.sh /entrypoint.sh
    CMD ["/bin/bash", "/entrypoint.sh"]