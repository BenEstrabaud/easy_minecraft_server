#!/bin/bash
# Downloads Chunky chunk pregenerator mod from Modrinth (Fabric version)

set -e

MODS_DIR="./fabric/mods"
mkdir -p "$MODS_DIR"

echo "Fetching Chunky from Modrinth..."

RESPONSE=$(curl -s "https://api.modrinth.com/v2/project/chunky/version?loaders=%5B%22fabric%22%5D")

# Use Python to find the first version compatible with 1.21.x
VERSION_INFO=$(echo "$RESPONSE" | python3 -c "
import sys, json
data = json.load(sys.stdin)
for v in data:
    if 'fabric' in v['loaders']:
        for gv in v['game_versions']:
            if gv.startswith('1.21'):
                for f in v['files']:
                    if f['filename'].endswith('.jar'):
                        print(f['url'])
                        print(f['filename'])
                        sys.exit(0)
sys.exit(1)
" 2>/dev/null) || true

if [ -z "$VERSION_INFO" ]; then
  echo "Error: Could not fetch Chunky"
  echo "Visit https://modrinth.com/mod/chunky to download manually"
  exit 1
fi

DOWNLOAD_URL=$(echo "$VERSION_INFO" | head -1)
FILENAME=$(echo "$VERSION_INFO" | tail -1)

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
