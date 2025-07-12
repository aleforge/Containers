FROM  ubuntu:24.04

LABEL author="AleForge Support" maintainer="support@mail.aleforge.net"
LABEL org.opencontainers.image.source="https://github.com/aleforge/containers/"
LABEL org.opencontainers.image.description="A Docker image to run Holdfast NAW on AleForge Panel (https://panel.aleforge.net)" 

## install required packages
ARG             DEBIAN_FRONTEND=noninteractive
RUN             dpkg --add-architecture i386
RUN             apt update
RUN             apt -y upgrade
RUN             apt install -y --no-install-recommends \
                    apt-transport-https \
                    binutils \
                    ca-certificates \
                    cabextract \
                    curl \
                    ffmpeg \
                    g++ \
                    gcc \
                    gdb \
                    git \
                    gnupg2 \
					gnutls-bin \
                    icu-devtools \
                    iproute2 \
                    locales \
                    net-tools \
                    netcat-openbsd \
                    procps \
                    python3 \
                    rapidjson-dev \
                    software-properties-common \
                    sqlite3 \
                    tar \
                    telnet \
                    tini \
                    tzdata \
                    unzip \
                    wget \
                    winbind \
                    xauth \
                    xvfb \
                    xz-utils \
                    zip \
                    libatomic1 \
                    libc++-dev \
                    libc6 \
                    libduktape207 \
                    libevent-dev \
                    libfluidsynth3 \
                    libfontconfig \
                    libgcc1 \
                    libicu74 \
                    liblua5.4-0 \
                    liblzo2-2 \
                    libmariadbclient-dev-compat \
                    libncurses6:i386 \
                    libntlm0 \
                    libprotobuf32 \
                    libsdl1.2debian \
                    libsdl2-2.0-0 \
                    libsdl2-2.0-0:i386 \
                    libsqlite3-dev \
                    libstdc++6 \
                    libunwind8 \
                    libz-dev \
                    libzip4

RUN 			apt-get clean \
				&& rm -rf /var/lib/apt/lists/*

## Steamclient.so Link
RUN ln -s "/home/container/steamcmd/linux64/steamclient.so" "/usr/lib/x86_64-linux-gnu/steamclient.so" 

                ## Temp fix for things that still need libssl1.1
    RUN         if [ "$(uname -m)" = "x86_64" ]; then \
                    wget http://archive.ubuntu.com/ubuntu/pool/main/o/openssl/libssl1.1_1.1.0g-2ubuntu4_amd64.deb && \
                    dpkg -i libssl1.1_1.1.0g-2ubuntu4_amd64.deb && \
                    rm libssl1.1_1.1.0g-2ubuntu4_amd64.deb; \
                fi
    
    # Set the locale
    RUN        	sed -i '/en_US.UTF-8/s/^# //g' /etc/locale.gen && \
                   locale-gen
    ENV      	LANG=en_US.UTF-8
    ENV       	LANGUAGE=en_US:en
    ENV        	LC_ALL=en_US.UTF-8
    
    ## Setup user and working directory
    RUN         useradd -m -d /home/container -s /bin/bash container
    USER        container
    ENV         USER=container HOME=/home/container
    WORKDIR     /home/container
    
    STOPSIGNAL SIGINT
    
    COPY        --chown=container:container ../entrypoint.sh /entrypoint.sh
    RUN         chmod +x /entrypoint.sh
    ENTRYPOINT    ["/usr/bin/tini", "-g", "--"]
    CMD         ["/entrypoint.sh"]