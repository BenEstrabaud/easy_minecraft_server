# Minecraft Server (Docker)

Containerized Minecraft server supporting both **PaperMC** and **Fabric**, optimized for small deployments (1-2 players, 2 cores, 3GB RAM).

## Quick Start

```bash
# PaperMC (plugin-based)
docker compose --profile paper up -d

# Fabric (mod-based)
docker compose --profile fabric up -d

# View logs (wait for "Done" message)
docker compose logs -f
```

World borders for all dimensions are set automatically on startup based on `.env` settings.

## Server Types

| Feature | PaperMC | Fabric |
|---|---|---|
| Extension type | Plugins (Bukkit/Spigot API) | Mods (Fabric API) |
| Built-in optimizations | Yes (patched server) | No (add optimization mods) |
| Web map | Squaremap (port 8080) | BlueMap (port 8100) |
| Plugin/mod ecosystem | Large (Hangar, SpigotMC) | Large (Modrinth, CurseForge) |
| Best for | Vanilla+ with admin tools | Modular performance tuning |

Both use the same world data directory (`./data/`), so you can switch between them. Stop one profile before starting the other.

## PaperMC Setup

```bash
# Core admin commands (EssentialsX)
./setup/paper-essentials.sh

# Web map viewer
./setup/paper-squaremap.sh

# Proximity voice chat
./setup/paper-voicechat.sh

# Chunk pregenerator
./setup/paper-chunky.sh

# Restart to load plugins
docker compose --profile paper restart minecraft-paper
```

**EssentialsX** adds utility commands: `/home`, `/sethome`, `/back`, `/spawn`, `/tpa`, etc.

**Squaremap** web UI: `http://your-server:8080`

## Fabric Setup

```bash
# Performance mods (Lithium, FerriteCore, Krypton, C2ME, ServerCore)
./setup/fabric-optimization.sh

# Web map viewer (BlueMap)
./setup/fabric-bluemap.sh

# Proximity voice chat
./setup/fabric-voicechat.sh

# Chunk pregenerator
./setup/fabric-chunky.sh

# Restart to load mods
docker compose --profile fabric restart minecraft-fabric
```

**BlueMap** web UI: `http://your-server:8100`

## Shared Features

These work with both PaperMC and Fabric.

### Datapacks

```bash
./setup/common-datapacks.sh
```

Datapacks are vanilla Minecraft features and work with any server type.

### Chunk Pregeneration

After installing Chunky (Paper or Fabric version):

```bash
# Pregenerate overworld (uses world border automatically)
docker exec minecraft-server rcon-cli --host 127.0.0.1 "chunky worldborder"
docker exec minecraft-server rcon-cli --host 127.0.0.1 "chunky start"

# Monitor progress
docker compose logs -f

# After overworld completes, do nether
docker exec minecraft-server rcon-cli --host 127.0.0.1 "chunky world world_nether"
docker exec minecraft-server rcon-cli --host 127.0.0.1 "chunky worldborder"
docker exec minecraft-server rcon-cli --host 127.0.0.1 "chunky start"

# Then the end
docker exec minecraft-server rcon-cli --host 127.0.0.1 "chunky world world_the_end"
docker exec minecraft-server rcon-cli --host 127.0.0.1 "chunky worldborder"
docker exec minecraft-server rcon-cli --host 127.0.0.1 "chunky start"

# Pause/resume if needed
docker exec minecraft-server rcon-cli --host 127.0.0.1 "chunky pause"
docker exec minecraft-server rcon-cli --host 127.0.0.1 "chunky continue"
```

### Console Access

**Option 1: Docker attach**
```bash
docker attach minecraft-server
# Detach with Ctrl+P, Ctrl+Q
```

**Option 2: RCON CLI**
```bash
# Single command
docker exec minecraft-server rcon-cli --host 127.0.0.1 "list"

# Interactive mode
docker exec -i minecraft-server rcon-cli --host 127.0.0.1
```
Note: `--host 127.0.0.1` is required because Minecraft RCON only listens on IPv4.

**Option 3: Web RCON (optional)**
```bash
docker compose --profile paper --profile rcon up -d
# Access at http://your-server:4326
```

### Whitelist

Whitelist is enabled by default. Add players in `.env`:

```env
WHITELIST=Player1,Player2,Player3
```

Then recreate the container:
```bash
docker compose --profile paper up -d --force-recreate
```

Or manage at runtime via RCON:
```bash
docker exec minecraft-server rcon-cli --host 127.0.0.1 "whitelist add PlayerName"
docker exec minecraft-server rcon-cli --host 127.0.0.1 "whitelist remove PlayerName"
docker exec minecraft-server rcon-cli --host 127.0.0.1 "whitelist list"
```

## Migrating from Paper to Fabric

A migration script handles the full process — backup, stop, install mods, and start Fabric:

```bash
./setup/migrate-paper-to-fabric.sh
```

The script will:
1. Save all world data via RCON
2. Create a timestamped backup of `data/`
3. Stop the Paper server
4. Install Fabric optimization mods (if not already present)
5. Start the Fabric server

**What transfers automatically:**
- All world data (overworld, nether, the end)
- Player inventories, positions, advancements, statistics
- Whitelist, ops, banned players
- World border settings (re-applied on startup)
- Datapacks

**What does NOT transfer:**
- EssentialsX data (homes, warps, economy) — no Fabric equivalent
- Squaremap renders — BlueMap generates its own 3D map
- Plugin configs in `data/plugins/` — left on disk, ignored by Fabric

After migration, install Fabric equivalents for your plugins:

```bash
./setup/fabric-bluemap.sh       # Web map (replaces Squaremap)
./setup/fabric-voicechat.sh     # Voice chat (same mod, Fabric version)
./setup/fabric-chunky.sh        # Chunk pregenerator
docker compose --profile fabric restart minecraft-fabric
```

To revert, the script prints a restore command using the backup it created.

## Migrating from Fabric to Paper

```bash
./setup/migrate-fabric-to-paper.sh
```

The script will:
1. Save all world data via RCON
2. Create a timestamped backup of `data/`
3. Stop the Fabric server
4. Install EssentialsX plugin (if `paper/plugins/` is empty)
5. Start the Paper server

**What transfers automatically:**
- All world data (overworld, nether, the end)
- Player inventories, positions, advancements, statistics
- Whitelist, ops, banned players
- World border settings (re-applied on startup)
- Datapacks

**What does NOT transfer:**
- Mod data (ServerCore config, BlueMap renders, etc.)
- Mod-specific configs in `data/config/` — left on disk, ignored by Paper

After migration, install Paper equivalents for your mods:

```bash
./setup/paper-squaremap.sh     # Web map (replaces BlueMap)
./setup/paper-voicechat.sh     # Voice chat (Paper version)
./setup/paper-chunky.sh        # Chunk pregenerator
docker compose --profile paper restart minecraft-paper
```

To revert, the script prints a restore command using the backup it created.

## Switching Server Types

Both profiles share the same `./data/` directory. World data is compatible between Paper and Fabric. Only one can run at a time (they share `container_name: minecraft-server`).

```bash
# Stop current server
docker compose --profile paper down

# Start the other
docker compose --profile fabric up -d
```

Plugins and mods are not interchangeable. Paper plugins go in `paper/plugins/`, Fabric mods go in `fabric/mods/`.

## Directory Structure

```
minecraft/
├── docker-compose.yml
├── .env                      # Configuration
├── paper/
│   ├── plugins/              # PaperMC plugin JARs
│   └── config/               # Paper config files
├── fabric/
│   └── mods/                 # Fabric mod JARs
├── setup/
│   ├── paper-squaremap.sh    # Squaremap web map
│   ├── paper-essentials.sh   # EssentialsX admin commands
│   ├── paper-voicechat.sh    # Simple Voice Chat (Paper)
│   ├── paper-chunky.sh       # Chunky pregenerator (Paper)
│   ├── fabric-optimization.sh # Lithium, FerriteCore, etc.
│   ├── fabric-bluemap.sh     # BlueMap web map
│   ├── fabric-voicechat.sh   # Simple Voice Chat (Fabric)
│   ├── fabric-chunky.sh      # Chunky pregenerator (Fabric)
│   ├── common-datapacks.sh   # Vanilla datapacks
│   ├── migrate-paper-to-fabric.sh  # Paper → Fabric migration
│   └── migrate-fabric-to-paper.sh  # Fabric → Paper migration
└── data/                     # Server data (auto-created)
```

## Configuration

Edit `.env` to customize:
- `VERSION` - Minecraft version
- `MEMORY` - JVM heap size
- `VIEW_DISTANCE` / `SIMULATION_DISTANCE` - Chunk loading
- `SEED` - World seed
- `WORLD_BORDER` - Overworld/End border diameter (default: 5000)
- `NETHER_BORDER` - Nether border diameter (default: 625, should be WORLD_BORDER/8)
- `RCON_PASSWORD` - Minecraft RCON password (change this!)
- `RWA_USERNAME` / `RWA_PASSWORD` - RCON web admin login
- `ENABLE_WHITELIST` - Enable whitelist (default: true)
- `WHITELIST` - Comma-separated Minecraft usernames

## Ports

| Port | Service |
|---|---|
| 25565 | Minecraft server |
| 8080 | Squaremap web UI (Paper) |
| 8100 | BlueMap web UI (Fabric) |
| 24454/udp | Simple Voice Chat |
| 4326 | RCON web UI (optional) |
| 4327 | RCON websocket (optional) |

## Useful Commands

```bash
# Stop server
docker compose --profile paper down
# or
docker compose --profile fabric down

# Backup world
tar -czf backup-$(date +%Y%m%d).tar.gz data/world*

# Update server
docker compose pull
docker compose --profile paper up -d

# View resource usage
docker stats minecraft-server
```

## Firewall (Ubuntu)

```bash
sudo ufw allow 25565/tcp   # Minecraft
sudo ufw allow 8080/tcp    # Squaremap (Paper, if needed externally)
sudo ufw allow 8100/tcp    # BlueMap (Fabric, if needed externally)
sudo ufw allow 24454/udp   # Simple Voice Chat
sudo ufw allow 4326/tcp    # RCON web UI (if needed externally)
sudo ufw allow 4327/tcp    # RCON websocket (if needed externally)
```
