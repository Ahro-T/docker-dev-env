# Docker Dev Environment

Disposable Docker development environment for daily work with Codex/OMX. This setup intentionally does not persist Docker volumes.

## Files

- `Dockerfile`: builds the development image.
- `docker-compose.yml`: starts the development container without persistent volumes.
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
gh --version
omx doctor
```

## Stop

```bash
exit
docker compose down
```

## Mental model

- `Dockerfile` = how to build the image.
- `docker-compose.yml` = how to run the container.
- No Docker volumes are configured, so container-local state is disposable.


## GitHub login

Inside the container, run:

```bash
gh auth login
```

Recommended choices:

- GitHub.com
- HTTPS
- Login with a web browser

GitHub login is not persisted. If you delete and recreate the container, run `gh auth login` again.


## No persistent volumes

This compose file deliberately has no `volumes:` section. That means container-local caches, login state, and files created only inside the container are disposable. Keep important project files in GitHub or another host-managed location.


## Podman note

This image explicitly creates `/workspace` before setting it as the working directory so `podman-compose` can start the container with `-w /workspace`.
