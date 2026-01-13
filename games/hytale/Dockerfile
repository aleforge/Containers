FROM 		--platform=$TARGETOS/$TARGETARCH ghcr.io/aleforge/containers:java-25

LABEL author="AleForge Support" maintainer="support@mail.aleforge.net"
LABEL org.opencontainers.image.source="https://github.com/aleforge/containers/"
LABEL org.opencontainers.image.description="A Docker image to run Valheim on AleForge Panel (https://panel.aleforge.net)" 

USER		root

COPY        --from=ghcr.io/aleforge/containers:java-25 entrypoint.sh /java.sh
RUN 		chmod +x /java.sh

USER        container
ENV         USER=container HOME=/home/container
WORKDIR     /home/container

COPY 		./entrypoint.sh /entrypoint.sh

CMD         [ "/bin/bash", "/entrypoint.sh" ]