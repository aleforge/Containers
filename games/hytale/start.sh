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
# Authenticate and create game session tokens
# ─────────────────────────────────────────────
REFRESH_TOKEN_FILE=".hytale-refresh-token.enc"
ACCESS_TOKEN=""
REFRESH_TOKEN=""

# Encryption key - uses environment variable or generates from machine-specific data
ENCRYPTION_KEY="${HYTALE_ENCRYPTION_KEY:-$(hostname)-$(cat /proc/sys/kernel/random/uuid | head -c 32)}"

# Helper function to encrypt refresh token
encrypt_token() {
  echo -n "$1" | openssl enc -aes-256-cbc -a -pbkdf2 -pass pass:"$ENCRYPTION_KEY" 2>/dev/null
}

# Helper function to decrypt refresh token
decrypt_token() {
  echo -n "$1" | openssl enc -aes-256-cbc -a -d -pbkdf2 -pass pass:"$ENCRYPTION_KEY" 2>/dev/null
}

# Migrate existing unencrypted token to encrypted storage
OLD_REFRESH_TOKEN_FILE=".hytale-refresh-token"
if [ -f "$OLD_REFRESH_TOKEN_FILE" ] && [ ! -f "$REFRESH_TOKEN_FILE" ]; then
  echo -e "${YELLOW}Migrating existing refresh token to encrypted storage...${NC}"
  OLD_TOKEN=$(cat "$OLD_REFRESH_TOKEN_FILE")
  
  if [ -n "$OLD_TOKEN" ]; then
    # Encrypt and save the old token
    encrypt_token "$OLD_TOKEN" > "$REFRESH_TOKEN_FILE"
    
    # Securely delete the old unencrypted token
    shred -u "$OLD_REFRESH_TOKEN_FILE" 2>/dev/null || rm -f "$OLD_REFRESH_TOKEN_FILE"
    
    echo -e "${GREEN}Migration complete - old token encrypted and deleted${NC}"
  else
    # Empty file, just remove it
    rm -f "$OLD_REFRESH_TOKEN_FILE"
  fi
fi

# Check if we have a stored refresh token
if [ -f "$REFRESH_TOKEN_FILE" ]; then
  echo -e "${YELLOW}Using stored refresh token...${NC}"
  ENCRYPTED_TOKEN=$(cat "$REFRESH_TOKEN_FILE")
  REFRESH_TOKEN=$(decrypt_token "$ENCRYPTED_TOKEN")
  
  # Get new access token using refresh token
  TOKEN_RESPONSE=$(curl -s -X POST "https://oauth.accounts.hytale.com/oauth2/token" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=hytale-server" \
    -d "grant_type=refresh_token" \
    -d "refresh_token=$REFRESH_TOKEN")
  
  ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
  NEW_REFRESH_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"refresh_token":"[^"]*"' | cut -d'"' -f4)
  
  # Update refresh token if we got a new one
  if [ -n "$NEW_REFRESH_TOKEN" ]; then
    encrypt_token "$NEW_REFRESH_TOKEN" > "$REFRESH_TOKEN_FILE"
    REFRESH_TOKEN="$NEW_REFRESH_TOKEN"
  fi
  
  if [ -z "$ACCESS_TOKEN" ]; then
    echo -e "${YELLOW}Refresh token expired or invalid, starting new authentication...${NC}"
    rm -f "$REFRESH_TOKEN_FILE"
  else
    echo -e "${GREEN}Access token obtained from refresh token${NC}"
  fi
fi

# If we don't have an access token yet, do device code flow
if [ -z "$ACCESS_TOKEN" ]; then
  echo -e "${YELLOW}Starting device code authentication...${NC}"
  
  # Step 1: Request device code
  DEVICE_RESPONSE=$(curl -s -X POST "https://oauth.accounts.hytale.com/oauth2/device/auth" \
    -H "Content-Type: application/x-www-form-urlencoded" \
    -d "client_id=hytale-server" \
    -d "scope=openid offline auth:server")
  
  DEVICE_CODE=$(echo "$DEVICE_RESPONSE" | grep -o '"device_code":"[^"]*"' | cut -d'"' -f4)
  USER_CODE=$(echo "$DEVICE_RESPONSE" | grep -o '"user_code":"[^"]*"' | cut -d'"' -f4)
  VERIFICATION_URI=$(echo "$DEVICE_RESPONSE" | grep -o '"verification_uri":"[^"]*"' | cut -d'"' -f4)
  VERIFICATION_URI_COMPLETE=$(echo "$DEVICE_RESPONSE" | grep -o '"verification_uri_complete":"[^"]*"' | cut -d'"' -f4)
  EXPIRES_IN=$(echo "$DEVICE_RESPONSE" | grep -o '"expires_in":[0-9]*' | cut -d':' -f2)
  POLL_INTERVAL=$(echo "$DEVICE_RESPONSE" | grep -o '"interval":[0-9]*' | cut -d':' -f2)
  
  if [ -z "$DEVICE_CODE" ]; then
    echo -e "${RED}ERROR: Could not get device code${NC}"
    echo -e "${RED}Response: $DEVICE_RESPONSE${NC}"
    exit 1
  fi
  
  # Step 2: Display instructions to user
  echo
  echo -e "${BLUE}====================================================================${NC}"
  echo -e "${YELLOW}DEVICE AUTHORIZATION REQUIRED${NC}"
  echo -e "${BLUE}====================================================================${NC}"
  echo -e "${GREEN}Visit: ${VERIFICATION_URI_COMPLETE}${NC}"
  echo
  echo -e "${YELLOW}Or manually visit: ${VERIFICATION_URI}${NC}"
  echo -e "${YELLOW}And enter code: ${USER_CODE}${NC}"
  echo -e "${BLUE}====================================================================${NC}"
  echo -e "${YELLOW}Waiting for authorization (expires in ${EXPIRES_IN} seconds)...${NC}"
  echo
  
  # Step 3: Poll for token
  MAX_ATTEMPTS=$((EXPIRES_IN / POLL_INTERVAL))
  ATTEMPT=0
  
  while [ $ATTEMPT -lt $MAX_ATTEMPTS ]; do
    sleep $POLL_INTERVAL
    
    TOKEN_RESPONSE=$(curl -s -X POST "https://oauth.accounts.hytale.com/oauth2/token" \
      -H "Content-Type: application/x-www-form-urlencoded" \
      -d "client_id=hytale-server" \
      -d "grant_type=urn:ietf:params:oauth:grant-type:device_code" \
      -d "device_code=$DEVICE_CODE")
    
    # Check if we got an access token
    ACCESS_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"access_token":"[^"]*"' | cut -d'"' -f4)
    
    if [ -n "$ACCESS_TOKEN" ]; then
      REFRESH_TOKEN=$(echo "$TOKEN_RESPONSE" | grep -o '"refresh_token":"[^"]*"' | cut -d'"' -f4)
      echo -e "${GREEN}Authentication successful!${NC}"
      
      # Store refresh token for future use
      if [ -n "$REFRESH_TOKEN" ]; then
        encrypt_token "$REFRESH_TOKEN" > "$REFRESH_TOKEN_FILE"
        echo -e "${GREEN}Refresh token encrypted and stored for future use${NC}"
      fi
      break
    fi
    
    # Check for errors
    ERROR=$(echo "$TOKEN_RESPONSE" | grep -o '"error":"[^"]*"' | cut -d'"' -f4)
    
    if [ "$ERROR" != "authorization_pending" ] && [ -n "$ERROR" ]; then
      echo -e "${RED}ERROR: $ERROR${NC}"
      echo -e "${RED}Response: $TOKEN_RESPONSE${NC}"
      exit 1
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
  done
  
  if [ -z "$ACCESS_TOKEN" ]; then
    echo -e "${RED}ERROR: Authorization timed out${NC}"
    exit 1
  fi
fi

# Step 4: Get available profiles
echo -e "${YELLOW}Creating game session...${NC}"
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

# Step 5: Create game session
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

# ─────────────────────────────────────────────
# Start server
# ─────────────────────────────────────────────
echo
echo -e "${GREEN}Starting Hytale server...${NC}"
echo

exec java \
  -Xms128M \
  -XX:MaxRAMPercentage=85.0 \
  #-Xmx${SERVER_MEMORY}M \
  -jar Server/HytaleServer.jar \
  --assets Assets.zip \
  --auth-mode "${AUTH_MODE}" \
  --bind "0.0.0.0:${SERVER_PORT}" \
  "${JAVA_ARGS[@]}"