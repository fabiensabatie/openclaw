#!/bin/sh
set -eu
CONFIG_DIR="/home/node/.openclaw"
CONFIG_PATH="$CONFIG_DIR/openclaw.json"
# Fail fast if Railway vars are missing
: "${OPENCLAW_GATEWAY_TOKEN:?OPENCLAW_GATEWAY_TOKEN is required}"
: "${MISSION_CONTROL_ORIGIN:?MISSION_CONTROL_ORIGIN is required}"
mkdir -p "$CONFIG_DIR"
# Always rewrite config from env so volume can't keep stale values
cat > "$CONFIG_PATH" <<EOF
{
  "gateway": {
    "host": "0.0.0.0",
    "port": 18789,
    "auth": {
      "token": "${OPENCLAW_GATEWAY_TOKEN}"
    },
    "controlUi": {
      "allowedOrigins": ["${MISSION_CONTROL_ORIGIN}"]
    }
  }
}
EOF
chown -R 1000:1000 /home/node/.openclaw /workspace || true
chmod 600 "$CONFIG_PATH" || true
echo "OpenClaw config written. Origin=${MISSION_CONTROL_ORIGIN}"
exec su node -s /bin/sh -c "node /app/openclaw.mjs gateway --allow-unconfigured"
