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

# Helper: download the latest Fabric-compatible version of a Modrinth mod for 1.21.x
download_mod() {
  local slug="$1"
  local name="$2"

  echo "Fetching $name from Modrinth..."

  # Get versions for fabric loader, find one compatible with 1.21.x
  local response
  response=$(curl -s "https://api.modrinth.com/v2/project/${slug}/version?loaders=%5B%22fabric%22%5D")

  # Use Python to find the first version compatible with 1.21.x (including 1.21.11, 1.21.4, etc)
  local version_info
  version_info=$(echo "$response" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for v in data:
    if 'fabric' in v['loaders']:
        for gv in v['game_versions']:
            if gv.startswith('1.21'):
                # Find the primary jar file
                for f in v['files']:
                    if f['filename'].endswith('.jar'):
                        print(f['url'])
                        print(f['filename'])
                        sys.exit(0)
sys.exit(1)
" 2>/dev/null) || true

  if [ -z "$version_info" ]; then
    echo "  Warning: Could not fetch $name - download manually from https://modrinth.com/mod/$slug"
    return 1
  fi

  local download_url
  download_url=$(echo "$version_info" | head -1)
  local filename
  filename=$(echo "$version_info" | tail -1)

  echo "  Downloading $filename..."
  curl -sL -o "$MODS_DIR/$filename" "$download_url"

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
# Note: C2ME requires Java 22+, skipping since Docker image uses Java 21
# download_mod "c2me-fabric" "C2ME"
download_mod "servercore" "ServerCore"

echo ""
echo "All optimization mods downloaded to $MODS_DIR/"
echo ""
echo "Restart the server to load mods:"
echo "  docker compose --profile fabric restart minecraft-fabric"
echo ""
echo "These mods require no configuration and work out of the box."
echo "ServerCore has optional config for further tuning in data/config/servercore/"
