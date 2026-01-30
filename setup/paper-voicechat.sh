#!/bin/bash
# Downloads Simple Voice Chat plugin from Hangar (Paper version)

set -e

PLUGINS_DIR="./paper/plugins"
mkdir -p "$PLUGINS_DIR"

echo "Fetching Simple Voice Chat from Hangar..."
VERSION=$(curl -s "https://hangar.papermc.io/api/v1/projects/SimpleVoiceChat/versions?limit=1" \
  | grep -o '"name":"[^"]*"' \
  | head -1 \
  | cut -d'"' -f4)

if [ -n "$VERSION" ]; then
  FILENAME="voicechat-bukkit-${VERSION}.jar"
  echo "Downloading Simple Voice Chat $VERSION..."
  curl -L -o "$PLUGINS_DIR/$FILENAME" \
    "https://hangar.papermc.io/api/v1/projects/SimpleVoiceChat/versions/${VERSION}/PAPER/download"
  # Remove old versions
  find "$PLUGINS_DIR" -name "voicechat-bukkit-*.jar" ! -name "$FILENAME" -delete 2>/dev/null || true
  echo ""
  echo "Simple Voice Chat downloaded to $PLUGINS_DIR/$FILENAME"
else
  echo "Error: Could not fetch Simple Voice Chat version"
  echo "Visit https://hangar.papermc.io/henkelmax/SimpleVoiceChat to download manually"
  exit 1
fi

echo ""
echo "Restart the server to load the plugin:"
echo "  docker compose --profile paper restart minecraft-paper"
echo ""
echo "IMPORTANT: Simple Voice Chat requires UDP port 24454"
echo "Open it in your firewall:"
echo "  sudo ufw allow 24454/udp"
echo ""
echo "Players need the Simple Voice Chat mod installed on their client."
