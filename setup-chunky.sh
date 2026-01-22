#!/bin/bash
# Downloads the Chunky chunk pregenerator plugin from Hangar

set -e

PLUGINS_DIR="./plugins"
mkdir -p "$PLUGINS_DIR"

echo "Fetching latest Chunky release from Hangar..."

# Get latest version info from Hangar API
VERSION=$(curl -s "https://hangar.papermc.io/api/v1/projects/Chunky/versions?limit=1" \
  | grep -o '"name":"[^"]*"' \
  | head -1 \
  | cut -d'"' -f4)

if [ -z "$VERSION" ]; then
  echo "Error: Could not determine latest Chunky version"
  echo "Visit https://hangar.papermc.io/pop4959/Chunky to download manually"
  exit 1
fi

DOWNLOAD_URL="https://hangar.papermc.io/api/v1/projects/Chunky/versions/${VERSION}/PAPER/download"
FILENAME="Chunky-Bukkit-${VERSION}.jar"

echo "Downloading Chunky $VERSION..."
curl -L -o "$PLUGINS_DIR/$FILENAME" "$DOWNLOAD_URL"

# Remove old versions
find "$PLUGINS_DIR" -name "Chunky-*.jar" ! -name "$FILENAME" -delete 2>/dev/null || true

echo ""
echo "Chunky downloaded to $PLUGINS_DIR/$FILENAME"
echo ""
echo "Restart the server to load the plugin:"
echo "  docker compose restart minecraft"
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
echo "  docker compose logs -f minecraft"
