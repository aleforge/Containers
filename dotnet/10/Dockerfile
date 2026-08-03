FROM        --platform=$TARGETOS/$TARGETARCH ghcr.io/aleforge/base:debian

LABEL       author="AleForge" maintainer="support@mail.aleforge.net"

ENV         DEBIAN_FRONTEND noninteractive

RUN         apt update -y \
            && apt upgrade -y \
            && apt install -y apt-transport-https wget curl iproute2 libgdiplus tini --no-install-recommends\
            && wget https://dot.net/v1/dotnet-install.sh \
            && chmod +x dotnet-install.sh \
            && ./dotnet-install.sh -i /usr/share -c 10.0 \
            && ln -s /usr/share/dotnet /usr/bin/dotnet \
            && rm -rf /var/lib/apt/lists/*

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./../entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
CMD         ["/entrypoint.sh"]
