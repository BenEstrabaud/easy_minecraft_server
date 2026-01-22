#!/bin/bash
# Downloads EssentialsX (from GitHub) and Simple Voice Chat (from Hangar)

set -e

PLUGINS_DIR="./plugins"
mkdir -p "$PLUGINS_DIR"

# EssentialsX (from GitHub)
echo "Fetching EssentialsX from GitHub..."
# Extract all download URLs, then filter to just the core EssentialsX jar
DOWNLOAD_URL=$(curl -s https://api.github.com/repos/EssentialsX/Essentials/releases/latest \
  | grep -oE 'https://github.com/EssentialsX/Essentials/releases/download/[^"]+\.jar' \
  | grep -E 'EssentialsX-[0-9]+\.[0-9]+\.[0-9]+\.jar$' \
  | head -1)

if [ -n "$DOWNLOAD_URL" ]; then
  FILENAME=$(basename "$DOWNLOAD_URL")
  echo "Downloading $FILENAME..."
  curl -L -o "$PLUGINS_DIR/$FILENAME" "$DOWNLOAD_URL"
  # Remove old versions
  find "$PLUGINS_DIR" -name "EssentialsX-*.jar" ! -name "$FILENAME" -delete 2>/dev/null || true
else
  echo "Error: Could not fetch EssentialsX"
  echo "Visit https://github.com/EssentialsX/Essentials/releases to download manually"
fi

# Simple Voice Chat
echo ""
echo "Fetching Simple Voice Chat..."
VERSION=$(curl -s "https://hangar.papermc.io/api/v1/projects/SimpleVoiceChat/versions?limit=1" \
  | grep -o '"name":"[^"]*"' \
  | head -1 \
  | cut -d'"' -f4)

if [ -n "$VERSION" ]; then
  echo "Downloading Simple Voice Chat $VERSION..."
  curl -L -o "$PLUGINS_DIR/voicechat-bukkit-${VERSION}.jar" \
    "https://hangar.papermc.io/api/v1/projects/SimpleVoiceChat/versions/${VERSION}/PAPER/download"
  rm -f "$PLUGINS_DIR"/voicechat-bukkit-[0-9]*.jar 2>/dev/null || true
else
  echo "Error: Could not fetch Simple Voice Chat version"
  echo "Visit https://hangar.papermc.io/henkelmax/SimpleVoiceChat to download manually"
fi

echo ""
echo "Done! Restart the server to load plugins:"
echo "  docker compose restart minecraft"
echo ""
echo "IMPORTANT: Simple Voice Chat requires UDP port 24454"
echo "Open it in your firewall:"
echo "  sudo ufw allow 24454/udp"
echo ""
echo "Players need the Simple Voice Chat mod installed on their client."
