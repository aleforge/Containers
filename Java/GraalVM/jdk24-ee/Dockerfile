FROM --platform=$TARGETOS/$TARGETARCH amd64/debian

LABEL author="AleForge Support" maintainer="support@mail.aleforge.net"
LABEL org.opencontainers.image.source="https://github.com/aleforge/containers/"
LABEL org.opencontainers.image.description="A Docker image to run GraalVM JDK 24 EE on AleForge Panel (https://panel.aleforge.net)" 

# Linux things
ARG DEBIAN_FRONTEND=noninteractive

# Installing GraalVM JDK 24 EE
ARG GRAALVM_VERSION=24.0.2
ARG GRAALVM_PKG=https://download.oracle.com/graalvm/24/latest/graalvm-jdk-24_linux-x64_bin.tar.gz 
ARG GRAALVM_FOLDER_NAME=graalvm-community-openjdk-${GRAALVM_VERSION}+9.1

RUN apt-get update -y \
    && apt-get upgrade -y \
    && apt-get install -y lsof curl ca-certificates openssl git tar sqlite3 fontconfig libfreetype6 tzdata iproute2 libstdc++6 locales locales-all font-manager --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Setting the language
RUN echo "Setting the language..."
ENV LANG='en_US.UTF-8'
ENV LANGUAGE='en_US.UTF-8'
ENV LC_ALL='en_US.UTF-8'
RUN sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && locale-gen

RUN echo ${GRAALVM_PKG}
RUN cd /usr/local/ \
    && echo "Downloading GraalVM..." && curl --retry 3 -Lfso /tmp/graalvm.tar.gz ${GRAALVM_PKG} \
    && echo "Extracting GraalVM..." \
    && mkdir -p /opt/graalvm \
    && tar -xzf /tmp/graalvm.tar.gz --strip-components=1 -C /opt/graalvm \
    && echo "Delete temp file..." && rm /tmp/graalvm.tar.gz

RUN echo "Moving GraalVM..." && mkdir /usr/local/graalvm && mv /usr/local/${GRAALVM_FOLDER_NAME}/* /usr/local/graalvm && rm -rf /usr/local/${GRAALVM_FOLDER_NAME}

RUN echo "Setting GraalVM environment variables..."
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV JAVA_HOME=/opt/graalvm
ENV PATH=/opt/graalvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

# Check if the installation was successful
RUN java -version 

# Pterodactyl things
RUN useradd -d /home/container -m container

USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

COPY ./../entrypoint.sh /entrypoint.sh
CMD [ "/bin/bash", "/entrypoint.sh" ]
