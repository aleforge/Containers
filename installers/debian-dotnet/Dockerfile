FROM        --platform=$TARGETOS/$TARGETARCH debian:bookworm-slim

LABEL       author="AleForge" maintainer="support@mail.aleforge.net"

LABEL       org.opencontainers.image.source="https://github.com/aleforge/containers"
LABEL       org.opencontainers.image.licenses=MIT

ENV         DEBIAN_FRONTEND=noninteractive

RUN      apt update && apt upgrade -y \
         && apt -y --no-install-recommends install ca-certificates curl git unzip zip tar jq wget

# Only install the needed steamcmd packages on the AMD64 build
RUN         if [ "$(uname -m)" = "x86_64" ]; then \
                dpkg --add-architecture i386 && \
                apt update && \
                apt -y install lib32gcc-s1 libsdl2-2.0-0:i386 apt-transport-https wget curl iproute2 libgdiplus tini \
                && wget https://dot.net/v1/dotnet-install.sh \
                && D_V="$(curl -sSL https://dotnet.microsoft.com/en-us/download/dotnet/6.0 | grep -i  '<h3 id="sdk-6.*">SDK 6.*.*</h3>'  | head -1 | awk -F\" '{print $3}' | awk '{print $2;}' | sed 's/<\/h3>//g')" \   
                && chmod +x dotnet-install.sh \
                && ./dotnet-install.sh -i /usr/share -v $D_V \
                && ln -s /usr/share/dotnet /usr/bin/dotnet; \
            fi