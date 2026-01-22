#!/bin/bash
# Downloads and installs datapacks
# Usage: ./setup-datapacks.sh

set -e

DATAPACKS_DIR="./data/world/datapacks"

# Check if world exists
if [ ! -d "./data/world" ]; then
  echo "Error: World directory doesn't exist yet."
  echo "Start the server first to generate the world, then run this script."
  exit 1
fi

mkdir -p "$DATAPACKS_DIR"

echo ""
echo "=== Datapack Installation ==="
echo ""
echo "Vanilla Tweaks datapacks (including Player Head Drops) require manual download:"
echo ""
echo "1. Go to: https://vanillatweaks.net/picker/datapacks/"
echo "2. Select your Minecraft version"
echo "3. Choose datapacks (e.g., 'Player Head Drops' under Mobs)"
echo "4. Click 'Download Datapacks'"
echo "5. Copy the downloaded zip to: $DATAPACKS_DIR"
echo ""
echo "Then reload datapacks in-game:"
echo "  docker exec minecraft-server rcon-cli --host 127.0.0.1 'datapack list'"
echo "  docker exec minecraft-server rcon-cli --host 127.0.0.1 'reload'"
echo ""
echo "Or restart the server:"
echo "  docker compose restart minecraft"
echo ""

# List current datapacks
if [ -d "$DATAPACKS_DIR" ]; then
  echo "Current datapacks in $DATAPACKS_DIR:"
  ls -la "$DATAPACKS_DIR" 2>/dev/null || echo "  (none)"
fi
