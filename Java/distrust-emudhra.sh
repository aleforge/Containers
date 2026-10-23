#!/bin/bash
# CVE-2026-91403: drop the roots the compromised eMudhra intermediates chain to.
# A missing alias is left alone so this stays safe after a vendor build removes them.
set -euo pipefail

if [ -z "${JAVA_HOME:-}" ]; then
    echo "JAVA_HOME is not set" >&2
    exit 1
fi

if [ -f "${JAVA_HOME}/jre/lib/security/cacerts" ]; then
    store="${JAVA_HOME}/jre/lib/security/cacerts"
else
    store="${JAVA_HOME}/lib/security/cacerts"
fi

keytool -list -v -keystore "$store" -storepass changeit | awk '
    /^Alias name: / { alias = substr($0, 13) }
    /^Owner: / && /emSign ECC Root CA - G3|AAA Certificate Services/ { print alias }
' | while IFS= read -r alias; do
    [ -n "$alias" ] || continue
    echo "Removing trust anchor: ${alias}"
    keytool -delete -noprompt -keystore "$store" -storepass changeit -alias "$alias"
done
