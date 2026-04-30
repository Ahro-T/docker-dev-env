# Docker Dev Environment

Disposable Docker development environment for daily work with Codex/OMX.

## Files

- `Dockerfile`: builds the development image.
- `docker-compose.yml`: starts the development container and keeps useful caches in Docker volumes.
- `.gitignore`: prevents secrets, local state, and build output from being committed.
- `.env.example`: safe example environment file.

## Start

```bash
docker compose up -d --build
docker compose exec dev bash
```

## Verify inside the container

```bash
node -v
cargo --version
tmux -V
omx doctor
```

## Stop

```bash
exit
docker compose down
```

Avoid this unless you intentionally want to delete saved Codex/npm/cargo volumes:

```bash
docker compose down -v
```

## Mental model

- `Dockerfile` = how to build the image.
- `docker-compose.yml` = how to run the container.
- Docker volumes = saved storage that survives normal container deletion.
