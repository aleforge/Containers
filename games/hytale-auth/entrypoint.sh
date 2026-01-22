#!/bin/bash

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

# Information output
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Hytale Image from AleForge${NC}"
echo -e "${RED}THIS IMAGE IS LICENSED UNDER MIT${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Linux Distribution: ${RED}$(. /etc/os-release ; echo $PRETTY_NAME)${NC}"
echo -e "${YELLOW}Current timezone: $(cat /etc/timezone)${NC}"
echo -e "${YELLOW}Java Version:${NC}"
java -version
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

if [[ "$RUN_DOWNLOADER" == "1" ]]; then
  if [[ "$BRANCH" == "release" ]]; then
    # needs to be regularly rebuilt
    echo "Extracting cached version $(cat /hytale-release)..."
    bsdtar -xf /hytale-release.zip
    echo "Done extracting!"
  else
    cat > /tmp/.hytale-downloader-credentials.json <<EOF
{"access_token":"$HYTALE_TOKEN","refresh_token":"","expires_at":2500000000,"branch":"release"}
EOF
    ARGS="--credentials-path /tmp/.hytale-downloader-credentials.json --patchline $BRANCH"
    CURRENT_VERSION=$(hytale-downloader $ARGS --print-version)
    if [[ "$(cat hytale-version 2>/dev/null)" != "$CURRENT_VERSION" ]]; then
      hytale-downloader $ARGS --download-path ./hytale.zip  && bsdtar -xf hytale.zip && rm hytale.zip
      echo $CURRENT_VERSION>hytale-version
    else
      echo "Already up to date at $CURRENT_VERSION"
    fi
    # important that this always executes if above fails
    rm /tmp/.hytale-downloader-credentials.json
  fi
fi

if [[ "$AUTO_AUTH" == "1" ]]; then
  RESPONSE=$(curl -s -X POST "https://sessions.hytale.com/game-session/new" \
  -H "Authorization: Bearer $HYTALE_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"uuid": "'$HYTALE_PROFILE'"}')

  # Only useful for debugging, let's not scare administrators
  #echo $RESPONSE

  export HYTALE_SERVER_SESSION_TOKEN=$(echo "$RESPONSE" | jq -r ".sessionToken")
  export HYTALE_SERVER_IDENTITY_TOKEN=$(echo "$RESPONSE" | jq -r ".identityToken")
fi

unset HYTALE_TOKEN HYTALE_PROFILE

echo "Downloading essential mods..."

mkdir -vp mods

# Download latest nitrado-performance-saver
PERF_SAVER_URL=$(curl -s https://api.github.com/repos/nitrado/hytale-plugin-performance-saver/releases/latest | jq -r '.assets[0].browser_download_url')
curl -L -o "mods/$(basename "$PERF_SAVER_URL" | sed 's/nitrado-//')" "$PERF_SAVER_URL"

# Download latest nitrado-webserver
WEBSERVER_URL=$(curl -s https://api.github.com/repos/nitrado/hytale-plugin-webserver/releases/latest | jq -r '.assets[0].browser_download_url')
curl -L -o "mods/$(basename "$WEBSERVER_URL" | sed 's/nitrado-//')" "$WEBSERVER_URL"

# Download latest nitrado-query
QUERY_URL=$(curl -s https://api.github.com/repos/nitrado/hytale-plugin-query/releases/latest | jq -r '.assets[0].browser_download_url')
curl -L -o "mods/$(basename "$QUERY_URL" | sed 's/nitrado-//')" "$QUERY_URL"

PERMISSIONS=$(cat permissions.json 2>/dev/null)
if [[ "$PERMISSIONS" == "" ]]; then
  PERMISSIONS="{}"
fi

echo "$PERMISSIONS" | jq 'setpath(
  ["users","00000000-0000-0000-0000-000000000000","permissions"];
  (
    (.users["00000000-0000-0000-0000-000000000000"].permissions // [])
    + ["nitrado.query.web.read.players"]
    | unique
  )
)' >permissions.json

echo "Finished downloading essential mods! Now starting server..."

REPLACED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

exec $REPLACED
