#!/bin/bash

java -version

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

mkdir -vp mods && curl -L -o mods/nitrado-performance-saver-1.0.0.jar https://github.com/nitrado/hytale-plugin-performance-saver/releases/download/v1.0.0/nitrado-performance-saver-1.0.0.jar\
  && curl -L -o mods/nitrado-webserver-1.0.0.jar https://github.com/nitrado/hytale-plugin-webserver/releases/download/v1.0.0/nitrado-webserver-1.0.0.jar\
  && curl -L -o mods/nitrado-query-1.0.1.jar https://github.com/nitrado/hytale-plugin-query/releases/download/v1.0.1/nitrado-query-1.0.1.jar

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
