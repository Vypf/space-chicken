# Space Chicken

Multiplayer Godot 4.5 game with dynamic server spawning and lobby-based matchmaking.

## Architecture

- **Player clients** connect to a lobby server
- **Lobby server** spawns game server instances on-demand
- **Game servers** use WebSocket for multiplayer communication
- Players join games via 6-character codes (e.g., ABC123)

## Development

### Prerequisites

- Godot 4.5
- Docker (for containerized testing)

### Running Locally

**Player client:**
```bash
Godot_v4.5-stable_win64.exe --path .
```

**Lobby server:**
```bash
Godot_v4.5-stable_win64.exe --headless server_type=lobby --environment=development --log_folder=C:\space-chicken\logs --executable_paths space-chicken="C:\space-chicken\executables\Godot_v4.5-stable_win64.exe" --paths space-chicken=C:\space-chicken
```

**Game server (spawned automatically by lobby):**
```bash
Godot_v4.5-stable_win64.exe --headless server_type=room --code=ABC123 --port=18000
```

## Docker

### Build

```bash
docker build -t space-chicken:test .
```

### Test

**Prerequisites:** Lobby must be running on `localhost:17018`

**Test with lobby on host machine:**
```bash
docker run --rm -p 18000:18000 \
  space-chicken:test \
  server_type=room code=ABC123 port=18000 \
  --lobby_url=ws://host.docker.internal:17018
```

**Production (lobby in Docker):**
```bash
docker run --rm -p 18000:18000 \
  --network game-infrastructure_game-network \
  ghcr.io/YOUR_USERNAME/space-chicken:latest \
  server_type=room code=ABC123 port=18000 \
  --lobby_url=ws://game-lobby:17018
```

### Networking

| Scenario | Lobby | Server | lobby_url |
|----------|-------|--------|-----------|
| Test | Host | Docker | `ws://host.docker.internal:17018` |
| Production | Docker | Docker | `ws://game-lobby:17018` |

**Note:** On Linux, replace `host.docker.internal` with the bridge gateway IP (usually `172.17.0.1`).

## Deployment

### GitHub Container Registry

The workflow `.github/workflows/docker-publish.yml` automatically builds and pushes to GHCR on:
- Push to `main` or `dockerfile` branches
- Version tags (e.g., `v1.0.0`)

**Make image public:**
1. Go to https://github.com/users/YOUR_USERNAME/packages
2. Select `space-chicken`
3. Settings → Change visibility → Public

### Using Published Image

```bash
docker pull ghcr.io/YOUR_USERNAME/space-chicken:latest
```
