#!/bin/bash
# Downloads Fabric optimization mods from Modrinth:
# - Lithium (general server optimization)
# - FerriteCore (memory usage optimization)
# - Krypton (network stack optimization)
# - C2ME (chunk generation/loading optimization)
# - ServerCore (configurable server optimizations)

set -e

MODS_DIR="./fabric/mods"
mkdir -p "$MODS_DIR"

# Helper: download the latest Fabric-compatible version of a Modrinth mod
download_mod() {
  local slug="$1"
  local name="$2"

  echo "Fetching $name from Modrinth..."

  # Get latest version for fabric loader
  local response
  response=$(curl -s "https://api.modrinth.com/v2/project/${slug}/version?loaders=%5B%22fabric%22%5D&limit=1")

  local download_url
  download_url=$(echo "$response" | grep -o '"url":"[^"]*\.jar"' | head -1 | cut -d'"' -f4)

  local filename
  filename=$(echo "$response" | grep -o '"filename":"[^"]*\.jar"' | head -1 | cut -d'"' -f4)

  if [ -z "$download_url" ] || [ -z "$filename" ]; then
    echo "  Warning: Could not fetch $name - download manually from https://modrinth.com/mod/$slug"
    return 1
  fi

  echo "  Downloading $filename..."
  curl -sL -o "$MODS_DIR/$filename" "$download_url"

  # Remove old versions (match by slug prefix)
  find "$MODS_DIR" -name "${slug}-*.jar" ! -name "$filename" -delete 2>/dev/null || true

  echo "  Done: $MODS_DIR/$filename"
}

echo "=== Fabric Optimization Mods ==="
echo ""

download_mod "lithium" "Lithium"
echo ""
download_mod "ferrite-core" "FerriteCore"
echo ""
download_mod "krypton" "Krypton"
echo ""
download_mod "c2me-fabric" "C2ME"
echo ""
download_mod "servercore" "ServerCore"

echo ""
echo "All optimization mods downloaded to $MODS_DIR/"
echo ""
echo "Restart the server to load mods:"
echo "  docker compose --profile fabric restart minecraft-fabric"
echo ""
echo "These mods require no configuration and work out of the box."
echo "ServerCore has optional config for further tuning in data/config/servercore/"
