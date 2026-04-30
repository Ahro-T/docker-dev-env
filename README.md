# Podman Dev Environment

Disposable Podman development environment for daily work with Codex/OMX. This setup intentionally does not persist volumes.

## Files

- `Containerfile`: builds the development image.
- `compose.yml`: starts the development container without persistent volumes.
- `.gitignore`: prevents secrets, local state, and build output from being committed.
- `.env.example`: safe example environment file.

## Start

```bash
podman compose up -d --build
podman compose exec dev bash
```

If your system uses the standalone Compose provider, these commands may be:

```bash
podman-compose up -d --build
podman-compose exec dev bash
```

## Verify inside the container

```bash
node -v
cargo --version
tmux -V
gh --version
codex --version
omx --version
omx doctor
```

## Codex / OMX setup

Inside the container, initialize Codex and OMX:

```bash
codex --login
omx setup
omx doctor
```

## Stop

```bash
exit
podman compose down
```

Or, with the standalone provider:

```bash
podman-compose down
```

## Mental model

- `Containerfile` = how to build the image.
- `compose.yml` = how to run the container.
- No volumes are configured, so container-local state is disposable.

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
