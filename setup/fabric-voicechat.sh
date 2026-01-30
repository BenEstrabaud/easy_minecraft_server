#!/bin/bash
# Downloads Simple Voice Chat mod from Modrinth (Fabric version)

set -e

MODS_DIR="./fabric/mods"
mkdir -p "$MODS_DIR"

echo "Fetching Simple Voice Chat from Modrinth..."

RESPONSE=$(curl -s "https://api.modrinth.com/v2/project/simple-voice-chat/version?loaders=%5B%22fabric%22%5D&limit=1")

DOWNLOAD_URL=$(echo "$RESPONSE" | grep -o '"url":"[^"]*\.jar"' | head -1 | cut -d'"' -f4)
FILENAME=$(echo "$RESPONSE" | grep -o '"filename":"[^"]*\.jar"' | head -1 | cut -d'"' -f4)

if [ -z "$DOWNLOAD_URL" ] || [ -z "$FILENAME" ]; then
  echo "Error: Could not fetch Simple Voice Chat"
  echo "Visit https://modrinth.com/mod/simple-voice-chat to download manually"
  exit 1
fi

echo "Downloading $FILENAME..."
curl -sL -o "$MODS_DIR/$FILENAME" "$DOWNLOAD_URL"

# Remove old versions
find "$MODS_DIR" -name "voicechat-fabric-*.jar" ! -name "$FILENAME" -delete 2>/dev/null || true

echo ""
echo "Simple Voice Chat downloaded to $MODS_DIR/$FILENAME"
echo ""
echo "Restart the server to load the mod:"
echo "  docker compose --profile fabric restart minecraft-fabric"
echo ""
echo "IMPORTANT: Simple Voice Chat requires UDP port 24454"
echo "Open it in your firewall:"
echo "  sudo ufw allow 24454/udp"
echo ""
echo "Players need the Simple Voice Chat mod installed on their client."
