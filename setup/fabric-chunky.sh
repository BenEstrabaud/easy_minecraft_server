#!/bin/bash
# Downloads Chunky chunk pregenerator mod from Modrinth (Fabric version)

set -e

MODS_DIR="./fabric/mods"
mkdir -p "$MODS_DIR"

echo "Fetching Chunky from Modrinth..."

RESPONSE=$(curl -s "https://api.modrinth.com/v2/project/chunky/version?loaders=%5B%22fabric%22%5D&limit=1")

DOWNLOAD_URL=$(echo "$RESPONSE" | grep -o '"url":"[^"]*\.jar"' | head -1 | cut -d'"' -f4)
FILENAME=$(echo "$RESPONSE" | grep -o '"filename":"[^"]*\.jar"' | head -1 | cut -d'"' -f4)

if [ -z "$DOWNLOAD_URL" ] || [ -z "$FILENAME" ]; then
  echo "Error: Could not fetch Chunky"
  echo "Visit https://modrinth.com/mod/chunky to download manually"
  exit 1
fi

echo "Downloading $FILENAME..."
curl -sL -o "$MODS_DIR/$FILENAME" "$DOWNLOAD_URL"

# Remove old versions
find "$MODS_DIR" -name "Chunky-*.jar" ! -name "$FILENAME" -delete 2>/dev/null || true

echo ""
echo "Chunky downloaded to $MODS_DIR/$FILENAME"
echo ""
echo "Restart the server to load the mod:"
echo "  docker compose --profile fabric restart minecraft-fabric"
echo ""
echo "Then pregenerate your world (5000x5000 = 2500 block radius):"
echo "  docker exec minecraft-server rcon-cli --host 127.0.0.1 'chunky radius 2500'"
echo "  docker exec minecraft-server rcon-cli --host 127.0.0.1 'chunky start'"
echo ""
echo "Or use your existing world border:"
echo "  docker exec minecraft-server rcon-cli --host 127.0.0.1 'chunky worldborder'"
echo "  docker exec minecraft-server rcon-cli --host 127.0.0.1 'chunky start'"
echo ""
echo "Monitor progress:"
echo "  docker compose logs -f minecraft-fabric"
