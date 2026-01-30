#!/bin/bash
# Migrates a running PaperMC server to Fabric
#
# What transfers:
#   - All world data (overworld, nether, the end)
#   - Player inventories, positions, advancements, statistics
#   - Whitelist, banned players/IPs, ops
#   - World border settings (re-applied on startup via RCON)
#   - Datapacks (vanilla feature, server-type independent)
#
# What does NOT transfer:
#   - Plugin data (EssentialsX homes/warps, economy, etc.)
#   - Squaremap renders (BlueMap will generate its own)
#   - Plugin configs in data/plugins/
#
# Paper-specific files left in data/ are harmless — Fabric ignores them.

set -e
cd "$(dirname "$0")/.."

BACKUP_NAME="backup-pre-fabric-$(date +%Y%m%d-%H%M%S).tar.gz"

echo "=== Paper → Fabric Migration ==="
echo ""

# Step 1: Check Paper is running
if ! docker compose --profile paper ps --status running 2>/dev/null | grep -q minecraft-paper; then
  echo "Paper server is not running."
  echo "If the server is already stopped, skip ahead — just run:"
  echo "  ./setup/fabric-optimization.sh"
  echo "  docker compose --profile fabric up -d"
  echo ""
  echo "If you want to migrate from a running server, start Paper first:"
  echo "  docker compose --profile paper up -d"
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

# Step 4: Stop Paper
echo "Step 3: Stopping Paper server..."
docker compose --profile paper down
echo "  Paper server stopped."
echo ""

# Step 5: Install Fabric mods
echo "Step 4: Installing Fabric mods..."
if [ ! -d "fabric/mods" ] || [ -z "$(ls -A fabric/mods/ 2>/dev/null)" ]; then
  echo "  No mods found in fabric/mods/ — running setup scripts..."
  echo ""
  ./setup/fabric-optimization.sh
  echo ""
else
  echo "  Mods already present in fabric/mods/"
fi

# Step 6: Start Fabric
echo ""
echo "Step 5: Starting Fabric server..."
docker compose --profile fabric up -d

echo ""
echo "=== Migration complete ==="
echo ""
echo "Monitor startup:"
echo "  docker compose logs -f minecraft-fabric"
echo ""
echo "The server will use your existing world data, player data, and whitelist."
echo ""
echo "Recommended next steps:"
echo "  ./setup/fabric-bluemap.sh      # Web map (replaces Squaremap)"
echo "  ./setup/fabric-voicechat.sh    # Voice chat (Fabric version)"
echo "  ./setup/fabric-chunky.sh       # Chunk pregenerator (Fabric version)"
echo "  docker compose --profile fabric restart minecraft-fabric"
echo ""
echo "Your backup is at: $BACKUP_NAME"
echo "To revert: docker compose --profile fabric down && tar -xzf $BACKUP_NAME && docker compose --profile paper up -d"
