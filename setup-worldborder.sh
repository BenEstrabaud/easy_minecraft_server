#!/bin/bash
# Sets up the 5000x5000 world border via RCON
# Run this after the server has fully started

set -e

RCON_PASSWORD="${RCON_PASSWORD:-changeme}"

echo "Connecting to server RCON..."

docker exec -i minecraft-server rcon-cli --host 127.0.0.1 --password "$RCON_PASSWORD" << 'EOF'
worldborder center 0 0
worldborder set 5000
worldborder warning distance 100
worldborder warning time 15
EOF

echo "World border set to 5000x5000 centered at 0,0"
