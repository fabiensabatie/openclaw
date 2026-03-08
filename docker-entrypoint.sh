#!/bin/sh
set -eu

CONFIG_DIR="/data/.openclaw"
CONFIG_PATH="$CONFIG_DIR/openclaw.json"

# Required vars
: "${OPENCLAW_GATEWAY_TOKEN:?OPENCLAW_GATEWAY_TOKEN is required}"
: "${MISSION_CONTROL_ORIGIN:?MISSION_CONTROL_ORIGIN is required}"

# Normalize origin:
# - allow passing with or without https://
# - remove trailing slash
ORIGIN="$(printf '%s' "$MISSION_CONTROL_ORIGIN" | sed 's:/*$::')"
case "$ORIGIN" in
  http://*|https://*) ;;
  *) ORIGIN="https://$ORIGIN" ;;
esac

# Ensure OpenClaw uses the same state dir
export OPENCLAW_STATE_DIR="$CONFIG_DIR"

# Create required dirs
mkdir -p "$CONFIG_DIR" /data /workspace

# Always rewrite config from env
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

# Permissions for node user
chown -R 1000:1000 /data /workspace || true
chmod 600 "$CONFIG_PATH" || true

echo "OpenClaw config written to ${CONFIG_PATH}. Origin=${ORIGIN}"

# Run as node
exec su node -s /bin/sh -c "OPENCLAW_STATE_DIR='$CONFIG_DIR' node /app/openclaw.mjs gateway --bind lan --allow-unconfigured"
