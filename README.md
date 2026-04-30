# Podman Dev Environment

Podman development environment for daily work with Codex/OMX. Project files under `./workspace` are mounted into the container at `/workspace` so they are visible from the host GUI.

## Files

- `Containerfile`: builds the development image.
- `compose.yml`: starts the development container and mounts `./workspace` to `/workspace`.
- `.gitignore`: prevents secrets, local state, and build output from being committed.
- `.env.example`: safe example environment file.

## Start

```bash
mkdir -p workspace
podman compose up -d --build
podman compose exec dev bash
```

If your system uses the standalone Compose provider, these commands may be:

```bash
mkdir -p workspace
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
- `./workspace` on the host is mounted to `/workspace` in the container. Files there are visible in the host GUI and persist after container recreation.
- Container-local state outside `/workspace` is still disposable.

## GitHub login

Inside the container, run:

```bash
gh auth login
```

Recommended choices:

- GitHub.com
- HTTPS
- Login with a web browser

GitHub login is not persisted because only `/workspace` is mounted. If you delete and recreate the container, run `gh auth login` again.

## Workspace volume

The compose file mounts the host directory `./workspace` to `/workspace` in the container:

```yaml
volumes:
  - ./workspace:/workspace
```

If you use Podman on an SELinux host and get permission errors, change it to:

```yaml
volumes:
  - ./workspace:/workspace:Z
```

Before recreating an older no-volume container, copy any important existing files out of the container:

```bash
podman compose exec dev tar -C /workspace -cf - . | tar -C ./workspace -xf -
```

## Korean / UTF-8 tmux

The image generates `ko_KR.UTF-8`, exports `LANG`, `LC_ALL`, and `LC_CTYPE`, and writes `/root/.tmux.conf` with `tmux-256color` plus locale propagation so Korean text renders correctly inside tmux. `/root/.bashrc` also aliases `tmux` to `tmux -u`.

## Copying in tmux

Default prefix is `Ctrl-b`.

Mouse copy inside tmux:

1. Drag with the mouse to select text.
2. Release the mouse button; tmux copies the selection into its buffer and asks the terminal to sync it to the OS clipboard.
3. Press `Ctrl-b` then `]` to paste from the tmux buffer.

Keyboard copy inside tmux:

1. Press `Ctrl-b` then `[`.
2. Move to the start of the text with arrow keys.
3. Press `Ctrl-Space` to start selecting.
4. Move to the end of the text.
5. Press `Alt-w` or `Enter` to copy into the tmux buffer.
6. Press `Ctrl-b` then `]` to paste from the tmux buffer.

The image enables `set-clipboard on` and `terminal-features` clipboard support, so copying may also reach the host OS clipboard when the outer terminal supports tmux/OSC 52 clipboard integration. To bypass tmux and use the terminal's native selection, hold `Shift` while dragging in many terminals.

