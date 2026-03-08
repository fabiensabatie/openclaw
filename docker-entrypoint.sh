#!/bin/sh
set -e
CONFIG_DIR="/home/node/.openclaw"
CONFIG_PATH="$CONFIG_DIR/openclaw.json"
mkdir -p "$CONFIG_DIR"
# Write config only if missing (so persistent volume keeps it)
if [ ! -f "$CONFIG_PATH" ]; then
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
fi
chown -R 1000:1000 /home/node/.openclaw /workspace || true
chmod 600 "$CONFIG_PATH" || true
exec su node -s /bin/sh -c "node openclaw.mjs gateway --allow-unconfigured"
