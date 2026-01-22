FROM --platform=$TARGETOS/$TARGETARCH eclipse-temurin:25-jdk

LABEL author="AleForge" maintainer="info@aleforge.net"
LABEL org.opencontainers.image.source="https://github.com/aleforge/containers"
LABEL org.opencontainers.image.licenses=MIT

ENV DEBIAN_FRONTEND=noninteractive

RUN 		apt-get update -y \
				&& apt-get install -y curl libarchive-tools jq tini \
				&& useradd -d /home/container -m container

RUN curl https://downloader.hytale.com/hytale-downloader.zip | bsdtar -xf- hytale-downloader-linux-amd64 \
  && chmod +x hytale-downloader-linux-amd64 && mv hytale-downloader-linux-amd64 /usr/local/bin/hytale-downloader

RUN --mount=type=secret,id=access_token <<EOF
echo '{"access_token":"'$(cat /run/secrets/access_token)'","refresh_token":"","expires_at":2500000000,"branch":"release"}'>/tmp/.hytale-downloader-credentials.json
EOF

# We like TOCTOU!
RUN hytale-downloader --credentials-path /tmp/.hytale-downloader-credentials.json --print-version >hytale-release
RUN hytale-downloader --download-path /hytale-release.zip --credentials-path /tmp/.hytale-downloader-credentials.json

RUN rm /tmp/.hytale-downloader-credentials.json

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

STOPSIGNAL SIGINT

COPY        --chown=container:container ./entrypoint.sh /entrypoint.sh
RUN         chmod +x /entrypoint.sh
ENTRYPOINT  ["/usr/bin/tini", "-g", "--"]
CMD         ["/bin/bash", "/entrypoint.sh"]
