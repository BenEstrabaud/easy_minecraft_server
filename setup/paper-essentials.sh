#!/bin/bash
# Downloads EssentialsX plugin from GitHub

set -e

PLUGINS_DIR="./paper/plugins"
mkdir -p "$PLUGINS_DIR"

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
  echo ""
  echo "EssentialsX downloaded to $PLUGINS_DIR/$FILENAME"
else
  echo "Error: Could not fetch EssentialsX"
  echo "Visit https://github.com/EssentialsX/Essentials/releases to download manually"
  exit 1
fi

echo ""
echo "Restart the server to load the plugin:"
echo "  docker compose --profile paper restart minecraft-paper"
echo ""
echo "EssentialsX adds commands: /home, /sethome, /back, /spawn, /tpa, etc."
