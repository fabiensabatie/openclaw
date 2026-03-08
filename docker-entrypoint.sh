set -e
mkdir -p /home/node/.openclaw /workspace
chown -R 1000:1000 /home/node/.openclaw /workspace || true
exec su node -s /bin/sh -c "node dist/index.js"
