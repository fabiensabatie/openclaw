#!/bin/sh
set -eu

CONFIG_DIR="/home/node/.openclaw"
CONFIG_PATH="$CONFIG_DIR/openclaw.json"

# Required env vars
: "${OPENCLAW_GATEWAY_TOKEN:?OPENCLAW_GATEWAY_TOKEN is required}"
: "${MISSION_CONTROL_ORIGIN:?MISSION_CONTROL_ORIGIN is required}"

# Normalize origin:
# - accept with or without https://
# - remove trailing slashes
ORIGIN="$(printf '%s' "$MISSION_CONTROL_ORIGIN" | sed 's:/*$::')"
case "$ORIGIN" in
  http://*|https://*) ;;
  *) ORIGIN="https://$ORIGIN" ;;
esac

# Create required dirs as root before dropping privileges
mkdir -p "$CONFIG_DIR" /data

# Always rewrite config from env so stale volume config can't persist
cat > "$CONFIG_PATH" <<EOF
{
  "gateway": {
    "port": 18789,
    "auth": {
      "token": "${OPENCLAW_GATEWAY_TOKEN}"
    },
    "controlUi": {
      "allowedOrigins": ["${ORIGIN}"]
    }
  }
}
EOF

# Hand ownership to node user
chown -R 1000:1000 /home/node/.openclaw /data || true
chmod 600 "$CONFIG_PATH" || true

echo "OpenClaw config written. Origin=${ORIGIN}"

# Run OpenClaw as non-root
exec su node -s /bin/sh -c "node /app/openclaw.mjs gateway --bind lan --allow-unconfigured"
