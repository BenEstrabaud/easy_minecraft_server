#!/bin/bash
# Downloads BlueMap mod from Modrinth (web map viewer for Fabric)

set -e

MODS_DIR="./fabric/mods"
mkdir -p "$MODS_DIR"

echo "Fetching BlueMap from Modrinth..."

RESPONSE=$(curl -s "https://api.modrinth.com/v2/project/bluemap/version?loaders=%5B%22fabric%22%5D&limit=1")

DOWNLOAD_URL=$(echo "$RESPONSE" | grep -o '"url":"[^"]*\.jar"' | head -1 | cut -d'"' -f4)
FILENAME=$(echo "$RESPONSE" | grep -o '"filename":"[^"]*\.jar"' | head -1 | cut -d'"' -f4)

if [ -z "$DOWNLOAD_URL" ] || [ -z "$FILENAME" ]; then
  echo "Error: Could not fetch BlueMap"
  echo "Visit https://modrinth.com/mod/bluemap to download manually"
  exit 1
fi

echo "Downloading $FILENAME..."
curl -sL -o "$MODS_DIR/$FILENAME" "$DOWNLOAD_URL"

# Remove old versions
find "$MODS_DIR" -name "BlueMap-*-fabric*.jar" ! -name "$FILENAME" -delete 2>/dev/null || true
find "$MODS_DIR" -name "bluemap-*-fabric*.jar" ! -name "$FILENAME" -delete 2>/dev/null || true

echo ""
echo "BlueMap downloaded to $MODS_DIR/$FILENAME"
echo ""
echo "Restart the server to load the mod:"
echo "  docker compose --profile fabric restart minecraft-fabric"
echo ""
echo "Web UI will be at http://localhost:8100"
echo ""
echo "BlueMap generates a 3D map. First render may take a while."
echo "Configuration files are in data/config/bluemap/"
