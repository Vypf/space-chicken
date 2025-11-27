# Space Chicken

Jeu multijoueur Godot 4.5 avec génération dynamique de serveurs et matchmaking par lobby.

## Architecture

- **Clients joueurs** se connectent à un serveur lobby
- **Serveur lobby** génère des instances de serveur de jeu à la demande
- **Serveurs de jeu** utilisent WebSocket pour la communication multijoueur
- Les joueurs rejoignent les parties via des codes à 6 caractères (ex: ABC123)

## Développement

### Prérequis

- Godot 4.5

### Option 1 : Avec le lobby externe (Recommandé pour tester en conditions proches de la production)

Utiliser le projet [Vypf/lobby](https://github.com/Vypf/lobby) pour lancer l'infrastructure complète avec Docker :

1. **Démarrer l'infrastructure lobby :**
   ```bash
   git clone --recursive https://github.com/Vypf/lobby.git
   cd lobby
   docker compose -f docker-compose.yml -f docker-compose.dev.yml up -d --build
   ```

2. **Lancer 2+ clients joueurs** depuis Godot ou en ligne de commande :
   ```bash
   Godot_v4.5-stable_win64.exe --path . --server_url=localhost
   ```

3. Un joueur crée une partie, les autres rejoignent avec le code généré.

Le lobby est accessible à `ws://localhost/lobby` et les serveurs de jeu sont routés via `ws://localhost/{CODE}`.

### Option 2 : Tout dans Godot (Tests rapides en local)

Utiliser la fonctionnalité **Instances multiples** intégrée à Godot pour tout lancer depuis l'éditeur.

1. **Ouvrir Paramètres du projet** → Debug → Exécution → Instances multiples
2. **Activer** "Activer les instances multiples"
3. **Définir le nombre d'instances** souhaité (ex: 3 pour 2 joueurs + 1 lobby)
4. **Configurer chaque instance :**

| Instance | Arguments |
|----------|-----------|
| Joueur 1 | *(vide)* |
| Joueur 2 | *(vide)* |
| Lobby    | `--headless server_type=lobby --environment=development --log_folder=C:\chemin\vers\logs --executable_paths space-chicken="C:\chemin\vers\Godot.exe" --paths space-chicken=C:\chemin\vers\space-chicken` |

5. **Lancer** le projet (F5) - toutes les instances démarrent simultanément.

> **Note :** Dans ce mode, le lobby génère les serveurs de jeu comme processus Godot séparés via `OS.create_process()`.

### Arguments de configuration

| Argument | Utilisé par | Description |
|----------|-------------|-------------|
| `--server_url=HOST` | Clients | Serveur cible (défaut: `games.yvonnickfrin.dev`). Dérive les URLs du lobby (`wss://HOST/lobby`) et des game instances (`wss://HOST/{CODE}`) |
| `--lobby_url=URL` | Game servers Docker | URL complète pour s'enregistrer auprès du lobby interne (ex: `ws://game-lobby:17018`) |
| `--environment=development` | Tous | Active le mode développement (URLs en `ws://localhost:PORT` au lieu de dériver depuis `server_url`) |

**Exemples :**

```bash
# Client vers infra Docker locale
Godot_v4.5-stable_win64.exe --path . --server_url=localhost

# Client en mode développement pur (lobby local sur port 17018)
Godot_v4.5-stable_win64.exe --path . --environment=development

# Game server Docker vers lobby interne
server_type=room code=ABC123 port=18000 --lobby_url=ws://game-lobby:17018
```

## Docker

### Construction

```bash
docker build -t space-chicken:test .
```

### Test

**Prérequis :** Le lobby doit tourner sur `localhost:17018`

**Test avec le lobby sur la machine hôte :**
```bash
docker run --rm -p 18000:18000 \
  space-chicken:test \
  server_type=room code=ABC123 port=18000 \
  --lobby_url=ws://host.docker.internal:17018
```

**Production (lobby dans Docker) :**
```bash
docker run --rm -p 18000:18000 \
  --network game-infrastructure_game-network \
  ghcr.io/vypf/space-chicken:latest \
  server_type=room code=ABC123 port=18000 \
  --lobby_url=ws://game-lobby:17018
```

### Réseau

| Scénario | Lobby | Serveur | lobby_url |
|----------|-------|---------|-----------|
| Test | Hôte | Docker | `ws://host.docker.internal:17018` |
| Production | Docker | Docker | `ws://game-lobby:17018` |

**Note :** Sur Linux, remplacer `host.docker.internal` par l'IP de la passerelle bridge (généralement `172.17.0.1`).

## Déploiement

### GitHub Container Registry

Le workflow `.github/workflows/docker-publish.yml` construit et publie automatiquement sur GHCR lors de :
- Push sur les branches `main` ou `dockerfile`
- Tags de version (ex: `v1.0.0`)

**Rendre l'image publique :**
1. Aller sur https://github.com/users/vypf/packages
2. Sélectionner `space-chicken`
3. Settings → Change visibility → Public

### Utiliser l'image publiée

```bash
docker pull ghcr.io/vypf/space-chicken:latest
```
