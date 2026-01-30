#!/bin/bash
# Downloads the squaremap plugin from Hangar

set -e

PLUGINS_DIR="./paper/plugins"
mkdir -p "$PLUGINS_DIR"

echo "Fetching latest squaremap release from Hangar..."

# Get latest version info from Hangar API
VERSION=$(curl -s "https://hangar.papermc.io/api/v1/projects/squaremap/versions?limit=1" \
  | grep -o '"name":"[^"]*"' \
  | head -1 \
  | cut -d'"' -f4)

if [ -z "$VERSION" ]; then
  echo "Error: Could not determine latest squaremap version"
  echo "Visit https://hangar.papermc.io/jmp/squaremap to download manually"
  exit 1
fi

DOWNLOAD_URL="https://hangar.papermc.io/api/v1/projects/squaremap/versions/${VERSION}/PAPER/download"
FILENAME="squaremap-paper-${VERSION}.jar"

echo "Downloading squaremap $VERSION..."
curl -L -o "$PLUGINS_DIR/$FILENAME" "$DOWNLOAD_URL"

# Remove old versions
find "$PLUGINS_DIR" -name "squaremap-*.jar" ! -name "$FILENAME" -delete 2>/dev/null || true

echo ""
echo "squaremap downloaded to $PLUGINS_DIR/$FILENAME"
echo ""
echo "Restart the server to load the plugin:"
echo "  docker compose --profile paper restart minecraft-paper"
echo ""
echo "Web UI will be at http://localhost:8080"
echo ""
echo "Note: squaremap requires a compatible Minecraft version."
echo "Check https://hangar.papermc.io/jmp/squaremap for supported versions."
