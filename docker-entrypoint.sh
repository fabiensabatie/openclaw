#!/bin/sh
set -eu
mkdir -p /home/node/.openclaw
chown -R node:node /home/node/.openclaw
exec su -s /bin/sh node -c "node openclaw.mjs gateway --allow-unconfigured --bind lan"
