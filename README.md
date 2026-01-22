# PaperMC Minecraft Server (Docker)

Containerized PaperMC server optimized for small deployments (1-2 players, 2 cores, 3GB RAM).

## Quick Start

```bash
# Start the server
docker compose up -d

# View logs (wait for "Done" message)
docker compose logs -f minecraft
```

World borders for all dimensions are set automatically on startup based on `.env` settings.

## Adding Squaremap

```bash
chmod +x setup-squaremap.sh
./setup-squaremap.sh

# Restart to load the plugin
docker compose restart minecraft
```

Squaremap web UI: http://your-server:8080

## EssentialsX & Simple Voice Chat

```bash
chmod +x setup-essentials.sh
./setup-essentials.sh
docker compose restart minecraft
```

**EssentialsX** adds utility commands: `/home`, `/sethome`, `/back`, `/spawn`, `/tpa`, etc.

**Simple Voice Chat** adds proximity voice chat. Players need the mod installed on their client:
- https://modrinth.com/plugin/simple-voice-chat

## Chunk Pregeneration

Pregenerating chunks eliminates lag when exploring and populates the squaremap.

```bash
# Install Chunky plugin
chmod +x setup-chunky.sh
./setup-chunky.sh
docker compose restart minecraft

# Pregenerate overworld (uses world border automatically)
docker exec minecraft-server rcon-cli --host 127.0.0.1 "chunky worldborder"
docker exec minecraft-server rcon-cli --host 127.0.0.1 "chunky start"

# Monitor progress
docker compose logs -f minecraft

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

Pregeneration runs in the background. For a 5000x5000 world, expect several hours depending on CPU.

## Console Access

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
docker compose --profile rcon up -d
# Access at http://your-server:4326
```

## Directory Structure

```
minecraft/
├── docker-compose.yml
├── .env                 # Environment overrides
├── data/                # Server data (auto-created)
│   ├── world/
│   ├── plugins/
│   └── ...
├── plugins/             # Plugin JARs (read-only mount)
├── config/              # Config templates
└── setup-*.sh           # Setup scripts
```

## Configuration

Edit `.env` or `docker-compose.yml` to customize:
- `VERSION` - Minecraft version
- `MEMORY` - JVM heap size
- `VIEW_DISTANCE` / `SIMULATION_DISTANCE` - Chunk loading
- `SEED` - World seed
- `WORLD_BORDER` - Overworld/End border diameter (default: 5000)
- `NETHER_BORDER` - Nether border diameter (default: 625, should be WORLD_BORDER/8)
- `RCON_PASSWORD` - Minecraft RCON password (change this!)
- `RWA_USERNAME` / `RWA_PASSWORD` - RCON web admin login (default: admin/changeme)
- `ENABLE_WHITELIST` - Enable whitelist (default: true)
- `WHITELIST` - Comma-separated Minecraft usernames

## Whitelist

Whitelist is enabled by default. Add players in `.env`:

```env
WHITELIST=Player1,Player2,Player3
```

Then recreate the container:
```bash
docker compose up -d --force-recreate minecraft
```

Or manage at runtime via RCON:
```bash
# Add a player
docker exec minecraft-server rcon-cli --host 127.0.0.1 "whitelist add PlayerName"

# Remove a player
docker exec minecraft-server rcon-cli --host 127.0.0.1 "whitelist remove PlayerName"

# List whitelisted players
docker exec minecraft-server rcon-cli --host 127.0.0.1 "whitelist list"
```

## Ports

| Port      | Service                    |
|-----------|----------------------------|
| 25565     | Minecraft server           |
| 8080      | Squaremap web UI           |
| 24454/udp | Simple Voice Chat          |
| 4326      | RCON web UI (optional)     |
| 4327      | RCON websocket (optional)  |

## Useful Commands

```bash
# Stop server
docker compose down

# Backup world
tar -czf backup-$(date +%Y%m%d).tar.gz data/world*

# Update server
docker compose pull
docker compose up -d

# View resource usage
docker stats minecraft-server
```

## Firewall (Ubuntu)

```bash
sudo ufw allow 25565/tcp  # Minecraft
sudo ufw allow 8080/tcp   # Squaremap (if needed externally)
sudo ufw allow 24454/udp  # Simple Voice Chat
sudo ufw allow 4326/tcp   # RCON web UI (if needed externally)
sudo ufw allow 4327/tcp   # RCON websocket (if needed externally)
```
