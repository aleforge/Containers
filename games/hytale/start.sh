#!/bin/bash
set -e

cd /home/container || exit 1

# ─────────────────────────────────────────────
# Colors
# ─────────────────────────────────────────────
BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

# Information output
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}Hytale Image from AleForge${NC}"
echo -e "${RED}THIS IMAGE IS LICENSED UNDER AGPLv3${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"
echo -e "${YELLOW}"${YELLOW}Linux Distribution: ${RED} $(. /etc/os-release ; echo $PRETTY_NAME)${NC}" $(cat /etc/debian_version)${NC}"
echo -e "${YELLOW}Current timezone: $(cat /etc/timezone)${NC}"
echo -e "${YELLOW}Java Version:${NC} ${RED} $(java -version)${NC}"
echo -e "${BLUE}---------------------------------------------------------------------${NC}"

# ─────────────────────────────────────────────
# Egg variables / defaults
# ─────────────────────────────────────────────
SERVER_PORT="${SERVER_PORT:-5520}"
AUTH_MODE="${AUTH_MODE:-authenticated}"
ENABLE_BACKUPS="${ENABLE_BACKUPS:-false}"
BACKUP_DIR="${BACKUP_DIR:-backups}"
BACKUP_FREQUENCY="${BACKUP_FREQUENCY:-60}"

JAVA_ARGS=()
[ "${ACCEPT_EARLY_PLUGINS}" = "true" ] && JAVA_ARGS+=(--accept-early-plugins)
[ "${ALLOW_OP}" = "true" ] && JAVA_ARGS+=(--allow-op)

if [ "${ENABLE_BACKUPS}" = "true" ]; then
  JAVA_ARGS+=(--backup)
  JAVA_ARGS+=(--backup-dir "${BACKUP_DIR}")
  JAVA_ARGS+=(--backup-frequency "${BACKUP_FREQUENCY}")
fi

# ─────────────────────────────────────────────
# Ensure downloader exists
# ─────────────────────────────────────────────
if [ ! -f hytale-downloader ]; then
  echo -e "${YELLOW}Hytale downloader not found. Downloading...${NC}"
  curl -sSL -o hytale-downloader.zip https://downloader.hytale.com/hytale-downloader.zip >/dev/null 2>&1
  unzip -oq hytale-downloader.zip >/dev/null 2>&1
  mv hytale-downloader-linux-amd64 hytale-downloader >/dev/null 2>&1
  chmod +x hytale-downloader
  rm -f hytale-downloader-windows-amd64.exe QUICKSTART.md hytale-downloader.zip >/dev/null 2>&1
fi

echo -e "${BLUE}Hytale Downloader:${NC} $(./hytale-downloader -version 2>/dev/null || echo unknown)"
./hytale-downloader -check-update >/dev/null 2>&1 || true

# ─────────────────────────────────────────────
# Download server if missing
# ─────────────────────────────────────────────
if [ ! -f Server/HytaleServer.jar ]; then
  if [ ! -f .hytale-downloader-credentials.json ]; then
    echo -e "${YELLOW}Server not installed.${NC}"
    echo -e "${GREEN}Authentication required to download server files.${NC}"
    echo
    echo -e "${BLUE}When prompted:${NC}"
    echo " • Open the URL shown"
    echo " • Enter the device code"
    echo " • Complete login in your browser"
    echo
    echo -e "${RED}Do NOT restart the server during authentication.${NC}"
    echo
  else
    echo -e "${YELLOW}Server files missing, re-downloading...${NC}"
  fi

  ./hytale-downloader --skip-update-check || true
fi

# ─────────────────────────────────────────────
# Find downloaded patch ZIP
# ─────────────────────────────────────────────
PATCH_ZIP="$(ls -1 *.zip 2>/dev/null | grep -v Assets.zip | head -n1 || true)"

if [ -z "$PATCH_ZIP" ]; then
  echo -e "${RED}ERROR: No patch ZIP found after download.${NC}"
  exit 1
fi

# ─────────────────────────────────────────────
# Extract patch ZIP if server not present
# ─────────────────────────────────────────────
if [ ! -f Server/HytaleServer.jar ]; then
  echo -e "${YELLOW}Extracting server files from ${PATCH_ZIP}...${NC}"
  unzip -oq "$PATCH_ZIP" >/dev/null 2>&1
fi

# ─────────────────────────────────────────────
# Final sanity checks
# ─────────────────────────────────────────────
if [ ! -f Server/HytaleServer.jar ]; then
  echo -e "${RED}ERROR: Server/HytaleServer.jar still not found after extraction.${NC}"
  exit 1
fi

if [ ! -f Assets.zip ]; then
  echo -e "${RED}ERROR: Assets.zip not found after extraction.${NC}"
  exit 1
fi

# ─────────────────────────────────────────────
# Create game session tokens
# ─────────────────────────────────────────────
if [ -f .hytale-downloader-credentials.json ]; then
  echo -e "${YELLOW}Creating game session...${NC}"
  
  # Extract tokens from credentials file
  ACCESS_TOKEN=$(grep -o '"access_token":"[^"]*"' .hytale-downloader-credentials.json | cut -d'"' -f4)
  REFRESH_TOKEN=$(grep -o '"refresh_token":"[^"]*"' .hytale-downloader-credentials.json | cut -d'"' -f4)
  
  if [ -z "$REFRESH_TOKEN" ]; then
    echo -e "${RED}ERROR: Could not extract refresh token from .hytale-downloader-credentials.json${NC}"
    exit 1
  fi
  
  # Refresh the access token first
  echo -e "${YELLOW}Refreshing access token...${NC}"
  TOKEN_RESPONSE=$(curl -s -X POST "https://oauth.accounts.hytale.com/oauth2/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=hytale-server" \
    -d "grant_type=refresh_token" \
    -d "refresh_token=$REFRESH_TOKEN")
  
  # Extract new access token
  ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
  
  if [ -z "$ACCESS_TOKEN" ]; then
    echo -e "${RED}ERROR: Could not refresh access token${NC}"
    echo -e "${RED}Response: $TOKEN_RESPONSE${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}Access token refreshed${NC}"
  
  # Get available profiles
  PROFILE_RESPONSE=$(curl -s -X GET "https://account-data.hytale.com/my-account/get-profiles" \
    -H "Authorization: Bearer $ACCESS_TOKEN")
  
  # Extract profile UUID (first profile)
  PROFILE_UUID=$(echo "$PROFILE_RESPONSE" | grep -o '"uuid":"[^"]*"' | head -n1 | cut -d'"' -f4)
  
  if [ -z "$PROFILE_UUID" ]; then
    echo -e "${RED}ERROR: Could not extract profile UUID${NC}"
    echo -e "${RED}Response: $PROFILE_RESPONSE${NC}"
    exit 1
  fi
  
  echo -e "${GREEN}Profile UUID: ${PROFILE_UUID}${NC}"
  
  # Create game session
  SESSION_RESPONSE=$(curl -s -X POST "https://sessions.hytale.com/game-session/new" \
    -H "Authorization: Bearer $ACCESS_TOKEN" \
    -H "Content-Type: application/json" \
    -d "{\"uuid\": \"$PROFILE_UUID\"}")
  
  # Extract session and identity tokens
  SESSION_TOKEN=$(echo "$SESSION_RESPONSE" | grep -o '"sessionToken":"[^"]*"' | cut -d'"' -f4)
  IDENTITY_TOKEN=$(echo "$SESSION_RESPONSE" | grep -o '"identityToken":"[^"]*"' | cut -d'"' -f4)
  
  if [ -z "$SESSION_TOKEN" ] || [ -z "$IDENTITY_TOKEN" ]; then
    echo -e "${RED}ERROR: Could not extract session tokens${NC}"
    echo -e "${RED}Response: $SESSION_RESPONSE${NC}"
    exit 1
  fi
  
  # Export environment variables
  export HYTALE_SERVER_SESSION_TOKEN="$SESSION_TOKEN"
  export HYTALE_SERVER_IDENTITY_TOKEN="$IDENTITY_TOKEN"
  
  echo -e "${GREEN}Game session created successfully!${NC}"
else
  echo -e "${YELLOW}No credentials file found, skipping session creation${NC}"
fi

# ─────────────────────────────────────────────
# Start server
# ─────────────────────────────────────────────
echo
echo -e "${GREEN}Starting Hytale server...${NC}"
echo

exec java \
  -Xms128M \
  -Xmx${SERVER_MEMORY}M \
  -jar Server/HytaleServer.jar \
  --assets Assets.zip \
  --auth-mode "${AUTH_MODE}" \
  --bind "0.0.0.0:${SERVER_PORT}" \
  "${JAVA_ARGS[@]}"