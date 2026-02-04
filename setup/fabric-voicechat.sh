#!/bin/bash
# Downloads Simple Voice Chat mod from Modrinth (Fabric version)

set -e

MODS_DIR="./fabric/mods"
mkdir -p "$MODS_DIR"

echo "Fetching Simple Voice Chat from Modrinth..."

RESPONSE=$(curl -s "https://api.modrinth.com/v2/project/simple-voice-chat/version?loaders=%5B%22fabric%22%5D")

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
  echo "Error: Could not fetch Simple Voice Chat"
  echo "Visit https://modrinth.com/mod/simple-voice-chat to download manually"
  exit 1
fi

DOWNLOAD_URL=$(echo "$VERSION_INFO" | head -1)
FILENAME=$(echo "$VERSION_INFO" | tail -1)

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
