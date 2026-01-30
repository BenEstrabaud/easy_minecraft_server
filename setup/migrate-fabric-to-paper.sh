#!/bin/bash
# Migrates a running Fabric server to PaperMC
#
# What transfers:
#   - All world data (overworld, nether, the end)
#   - Player inventories, positions, advancements, statistics
#   - Whitelist, banned players/IPs, ops
#   - World border settings (re-applied on startup via RCON)
#   - Datapacks (vanilla feature, server-type independent)
#
# What does NOT transfer:
#   - Mod data (ServerCore config, BlueMap renders, etc.)
#   - Mod configs in data/config/ that are mod-specific
#
# Fabric-specific files left in data/ are harmless — Paper ignores them.

set -e
cd "$(dirname "$0")/.."

BACKUP_NAME="backup-pre-paper-$(date +%Y%m%d-%H%M%S).tar.gz"

echo "=== Fabric → Paper Migration ==="
echo ""

# Step 1: Check Fabric is running
if ! docker compose --profile fabric ps --status running 2>/dev/null | grep -q minecraft-fabric; then
  echo "Fabric server is not running."
  echo "If the server is already stopped, skip ahead — just run:"
  echo "  docker compose --profile paper up -d"
  echo ""
  echo "If you want to migrate from a running server, start Fabric first:"
  echo "  docker compose --profile fabric up -d"
  exit 1
fi

# Step 2: Save and backup
echo "Step 1: Saving world data..."
docker exec minecraft-server rcon-cli --host 127.0.0.1 "save-all flush" 2>/dev/null || true
sleep 3

echo "Step 2: Creating backup ($BACKUP_NAME)..."
tar -czf "$BACKUP_NAME" data/
echo "  Backup saved: $BACKUP_NAME"
echo ""

# Step 3: Verify world data exists
for dir in data/world data/world_nether data/world_the_end; do
  if [ -d "$dir" ]; then
    echo "  Found: $dir"
  fi
done

PLAYER_COUNT=$(find data/world/playerdata -name "*.dat" 2>/dev/null | wc -l | tr -d ' ')
echo "  Player data files: $PLAYER_COUNT"
echo ""

# Step 4: Stop Fabric
echo "Step 3: Stopping Fabric server..."
docker compose --profile fabric down
echo "  Fabric server stopped."
echo ""

# Step 5: Install Paper plugins
echo "Step 4: Checking Paper plugins..."
if [ ! -d "paper/plugins" ] || [ -z "$(ls -A paper/plugins/ 2>/dev/null)" ]; then
  echo "  No plugins found in paper/plugins/ — running setup scripts..."
  echo ""
  ./setup/paper-essentials.sh
  echo ""
else
  echo "  Plugins already present in paper/plugins/"
fi

# Step 6: Start Paper
echo ""
echo "Step 5: Starting Paper server..."
docker compose --profile paper up -d

echo ""
echo "=== Migration complete ==="
echo ""
echo "Monitor startup:"
echo "  docker compose logs -f minecraft-paper"
echo ""
echo "The server will use your existing world data, player data, and whitelist."
echo ""
echo "Recommended next steps:"
echo "  ./setup/paper-squaremap.sh     # Web map (replaces BlueMap)"
echo "  ./setup/paper-voicechat.sh     # Voice chat (Paper version)"
echo "  ./setup/paper-chunky.sh        # Chunk pregenerator (Paper version)"
echo "  docker compose --profile paper restart minecraft-paper"
echo ""
echo "Your backup is at: $BACKUP_NAME"
echo "To revert: docker compose --profile paper down && tar -xzf $BACKUP_NAME && docker compose --profile fabric up -d"
