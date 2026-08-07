#!/bin/bash

#
# Copyright (c) 2021 Matthew Penner
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

clear
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Wait for the container to fully initialize
sleep 1

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

current_timezone() {
    if [ -f /etc/timezone ]; then
        cat /etc/timezone
    elif [ -L /etc/localtime ]; then
        readlink /etc/localtime | sed 's|.*/zoneinfo/||'
    else
        date +%Z
    fi
}

# Information output
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${RED}SteamCMD Proton Image${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Linux Distribution: ${RED} $(. /etc/os-release ; echo $PRETTY_NAME) $(cat /etc/debian_version)${NC}"
echo -e "${YELLOW}Current timezone: ${RED} $(current_timezone)${NC}"
echo -e "${GREEN}Maintained by AleForge.net${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

# Install native steamclient.so where Proton 10/11 lsteamclient expects it.
# Missing these paths causes: "unable to load native steamclient library" + assert.
install_steamclient_libs() {
    local steam_root="/home/container/.steam/steam"
    local src64="/home/container/steamcmd/linux64/steamclient.so"
    local src32="/home/container/steamcmd/linux32/steamclient.so"

    mkdir -p \
        "${steam_root}/linux64" \
        "${steam_root}/linux32" \
        "${steam_root}/ubuntu12_64" \
        "${steam_root}/ubuntu12_32" \
        /home/container/.steam/sdk64 \
        /home/container/.steam/sdk32

    if [ -f "${src64}" ]; then
        cp -f "${src64}" "${steam_root}/linux64/steamclient.so"
        cp -f "${src64}" "${steam_root}/ubuntu12_64/steamclient.so"
        cp -f "${src64}" /home/container/.steam/sdk64/steamclient.so
    else
        echo -e "${YELLOW}WARNING: ${src64} not found; Proton may fail steamclient init${NC}"
    fi

    if [ -f "${src32}" ]; then
        cp -f "${src32}" "${steam_root}/linux32/steamclient.so"
        cp -f "${src32}" "${steam_root}/ubuntu12_32/steamclient.so"
        cp -f "${src32}" /home/container/.steam/sdk32/steamclient.so
    fi
}

# Headless display for Proton/Wine (explorer, Xalia fallbacks, SDL).
start_proton_display() {
    local display_num="${DISPLAY#:}"
    display_num="${display_num:-99}"
    export DISPLAY=":${display_num}"
    export DISPLAY_WIDTH="${DISPLAY_WIDTH:-1024}"
    export DISPLAY_HEIGHT="${DISPLAY_HEIGHT:-768}"
    export DISPLAY_DEPTH="${DISPLAY_DEPTH:-24}"

    mkdir -p /tmp/.X11-unix
    chmod 1777 /tmp/.X11-unix 2>/dev/null || true

    if [ -S "/tmp/.X11-unix/X${display_num}" ]; then
        return 0
    fi

    if command -v Xvfb >/dev/null 2>&1; then
        echo -e "${YELLOW}Starting Xvfb on DISPLAY=${DISPLAY}${NC}"
        Xvfb "${DISPLAY}" -screen 0 "${DISPLAY_WIDTH}x${DISPLAY_HEIGHT}x${DISPLAY_DEPTH}" -ac +extension GLX +render -noreset >/tmp/xvfb.log 2>&1 &
        sleep 1
    else
        echo -e "${YELLOW}WARNING: Xvfb not installed; Proton may fail window/display init${NC}"
    fi
}

# Set environment for Steam Proton
if [ -f "/usr/local/bin/proton" ]; then
    if [ ! -z ${SRCDS_APPID} ]; then
        mkdir -p /home/container/.steam/steam/steamapps/compatdata/${SRCDS_APPID}
        export STEAM_COMPAT_CLIENT_INSTALL_PATH="/home/container/.steam/steam"
        export STEAM_COMPAT_DATA_PATH="/home/container/.steam/steam/steamapps/compatdata/${SRCDS_APPID}"
        export WINETRICKS="/usr/sbin/winetricks"

        # Required for PROTON_LOG and lsteamclient outside the Steam client
        export SteamAppId="${SteamAppId:-${SRCDS_APPID}}"
        export SteamGameId="${SteamGameId:-${SRCDS_APPID}}"

        # Disable Xalia accessibility UI (SDL3) — crashes headless GE-Proton 11+
        export PROTON_USE_XALIA="${PROTON_USE_XALIA:-0}"

        install_steamclient_libs
        start_proton_display
    else
        echo -e "${BLUE}----------------------------------------------------------------------------------${NC}"
        echo -e "${RED}WARNING!!! Proton needs variable SRCDS_APPID, else it will not work. Please add it${NC}"
        echo -e "${RED}Server stops now${NC}"
        echo -e "${BLUE}----------------------------------------------------------------------------------${NC}"
        exit 0
    fi
fi

# Switch to the container's working directory
cd /home/container || exit 1

# -----------------------------------------------------------------------------
# NSS Wrapper Setup (opt-in on Proton images)
# -----------------------------------------------------------------------------
# Fakes the /etc/passwd entry for the dynamic Pterodactyl container user.
# Needed for some native C++ games (e.g. Avorion). Do NOT preload into Wine/
# Proton by default — it can break 32-bit steamcmd and Wine processes.
# Set ENABLE_NSS_WRAPPER=1 to force-enable.
if [ -f "/usr/lib/x86_64-linux-gnu/libnss_wrapper.so" ]; then
    export USER_ID=$(id -u)
    export GROUP_ID=$(id -g)
    export NSS_WRAPPER_PASSWD=/tmp/passwd
    export NSS_WRAPPER_GROUP=/etc/group
    echo "container:x:${USER_ID}:${GROUP_ID}:container:/home/container:/bin/bash" > ${NSS_WRAPPER_PASSWD}

    if [ "${ENABLE_NSS_WRAPPER}" = "1" ] || { [ ! -f "/usr/local/bin/proton" ] && [ "${ENABLE_NSS_WRAPPER}" != "0" ]; }; then
        export LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libnss_wrapper.so
    fi
fi
# -----------------------------------------------------------------------------

## just in case someone removed the defaults.
if [ "${STEAM_USER}" == "" ]; then
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Steam user is not set. ${NC}"
    echo -e "${YELLOW}Using anonymous user.${NC}"
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    STEAM_USER=anonymous
    STEAM_PASS=""
    STEAM_AUTH=""
else
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    echo -e "${YELLOW}user set to ${STEAM_USER} ${NC}"
    echo -e "${BLUE}---------------------------------------------------------------------${NC}"
fi

## if auto_update is not set or to 1 update
if [ -z ${AUTO_UPDATE} ] || [ "${AUTO_UPDATE}" == "1" ]; then
    # Update Source Server
    if [ ! -z ${SRCDS_APPID} ]; then
        # App 1007 = Steamworks shared redistributables (needed by many Windows/Proton servers)
        if [ "${STEAM_USER}" == "anonymous" ]; then
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update 1007 +app_update ${SRCDS_APPID} $( [[ -z ${STEAM_BETAID} ]] || printf %s "-beta ${STEAM_BETAID}" ) $( [[ -z ${STEAM_BETAPASS} ]] || printf %s "-betapassword ${STEAM_BETAPASS}" ) $( [[ -z ${HLDS_GAME} ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) $( [[ -z ${VALIDATE} ]] || printf %s "validate" ) +quit
        else
            ./steamcmd/steamcmd.sh +force_install_dir /home/container +login ${STEAM_USER} ${STEAM_PASS} ${STEAM_AUTH} $( [[ "${WINDOWS_INSTALL}" == "1" ]] && printf %s '+@sSteamCmdForcePlatformType windows' ) +app_update 1007 +app_update ${SRCDS_APPID} $( [[ -z ${STEAM_BETAID} ]] || printf %s "-beta ${STEAM_BETAID}" ) $( [[ -z ${STEAM_BETAPASS} ]] || printf %s "-betapassword ${STEAM_BETAPASS}" ) $( [[ -z ${HLDS_GAME} ]] || printf %s "+app_set_config 90 mod ${HLDS_GAME}" ) $( [[ -z ${VALIDATE} ]] || printf %s "validate" ) +quit
        fi
        # Refresh steamclient after steamcmd may have updated itself
        if [ -f "/usr/local/bin/proton" ]; then
            install_steamclient_libs
        fi
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}Starting Server${NC}"
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    else
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
        echo -e "${YELLOW}No appid set. Starting Server${NC}"
        echo -e "${BLUE}---------------------------------------------------------------------${NC}"
    fi

else
    echo -e "${BLUE}---------------------------------------------------------------${NC}"
    echo -e "${YELLOW}Not updating game server as auto update was set to 0. Starting Server${NC}"
    echo -e "${BLUE}---------------------------------------------------------------${NC}"
    if [ -f "/usr/local/bin/proton" ]; then
        install_steamclient_libs
    fi
fi

# Replace Startup Variables
MODIFIED_STARTUP=$(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')
echo -e ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server
eval ${MODIFIED_STARTUP}
