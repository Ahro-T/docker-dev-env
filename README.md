# Podman Dev Environment

Disposable Podman development environment for daily work with Codex/OMX. This setup intentionally does not use persistent volumes, so the container can be deleted and recreated from GitHub without preserving local state.

## Files

- `Containerfile`: builds the development image with Node, rustup-managed Rust, Codex, OMX, tmux, GitHub CLI, Korean UTF-8 locale support, non-secret OMX setup, and prebuilt OMX Rust helpers.
- `compose.yml`: starts the disposable development container without volumes.
- `scripts/bootstrap.sh`: verifies the baked tools and OMX health inside the container.
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
scripts/bootstrap.sh
```

The script checks:

```bash
node -v
cargo --version
rustc --version
rustup --version
tmux -V
gh --version
codex --version
omx --version
omx doctor
```

## Codex / GitHub login

No volumes are used, so login state is disposable. In each fresh container, run only the credentialed login steps you need:

```bash
codex --login
gh auth login
```

Do not commit login state, tokens, `.env`, `.codex/`, or `.omx/`.

## What is baked into the image

- Rust toolchain: rustup-managed stable `cargo` and `rustc` because Debian bookworm apt Rust is too old for current OMX native crates.
- Build packages needed by Rust/native Node tooling: `build-essential`, `pkg-config`, and `libssl-dev`.
- Codex CLI and oh-my-codex from npm.
- `omx setup --scope user --plugin --force` for non-secret OMX scaffolding.
- `cargo build --workspace --release` inside the installed `oh-my-codex` package so `omx explore`, `omx sparkshell`, and runtime helpers do not need first-use Rust builds in a fresh container.
- Korean UTF-8 locale and tmux clipboard/mouse configuration.

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

- `Containerfile` = reproducible image setup.
- `compose.yml` = disposable container runtime.
- No `volumes:` are configured. Container-local files, caches, login state, and workspace contents disappear when the container is removed.
- Keep important work in GitHub or another host-managed location by committing and pushing it.

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
