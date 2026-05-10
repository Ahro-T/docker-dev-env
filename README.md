# Podman Dev Environment

Disposable Podman development environment for daily work with Codex/OMX. The container keeps normal work in container-local `/workspace`; the host-mounted `./shared` directory is available only as a file exchange area at `/shared`.

## Files

- `Containerfile`: builds the development image with Node, rustup-managed Rust, Codex, OMX, tmux, GitHub CLI, Korean UTF-8 locale support, non-secret Codex/OMX defaults, warning suppression, HUD/status-line defaults, and prebuilt OMX Rust helpers.
- `compose.yml`: starts the development container with `/workspace` as the local working directory and `./shared` mounted separately at `/shared`.
- `scripts/bootstrap.sh`: verifies the baked tools and refreshes non-secret Codex/OMX settings inside the container. The image also installs it as `bootstrap-dev-env`.
- `scripts/configure-codex-omx.sh`: non-secret setup script baked into the image as `configure-codex-omx`; refreshes OMX setup, Codex warning suppression, HUD/status-line, feature flags, and native-agent defaults without copying credentials or logs.
- `.gitignore`: prevents secrets, local state, shared/export files, and build output from being committed.
- `.env.example`: safe example environment file.

## Start

```bash
git clone https://github.com/Ahro-T/docker-dev-env.git docker-env
cd docker-env
mkdir -p shared
podman compose up -d --build
podman compose exec dev bash
```

If your system uses the standalone Compose provider, these commands may be:

```bash
git clone https://github.com/Ahro-T/docker-dev-env.git docker-env
cd docker-env
mkdir -p shared
podman-compose up -d --build
podman-compose exec dev bash
```

## Verify inside the container

```bash
bootstrap-dev-env
# or, if you are running from a checked-out copy inside the container:
# scripts/bootstrap.sh
```

The script checks and refreshes:

```bash
node -v
cargo --version
rustc --version
rustup --version
tmux -V
gh --version
codex --version
omx --version
configure-codex-omx
omx doctor

# Also verifies the baked Codex/OMX defaults and compares installed Codex CLI against npm latest.
```

## Codex / GitHub login

Credential state is still disposable. In each fresh container, run only the credentialed login steps you need:

```bash
codex --login
gh auth login
```

Do not commit login state, tokens, `.env`, `.codex/`, or `.omx/`.

## What is baked into the image

- Rust toolchain: rustup-managed stable `cargo` and `rustc` because Debian bookworm apt Rust is too old for current OMX native crates.
- Build packages needed by Rust/native Node tooling: `build-essential`, `pkg-config`, and `libssl-dev`.
- Codex CLI and oh-my-codex from npm using explicit `@latest` tags at image build time.
- `configure-codex-omx` runs `omx setup --scope user --legacy --force`, then pins the non-secret Codex/OMX defaults that make the current environment clean: no unstable-feature warning, OMX HUD/status-line enabled, native hooks/goals/agents enabled, MCP servers configured by OMX, direct `~/.codex/skills`/`~/.codex/prompts` installation, and explore routing enabled.
- `cargo build --workspace --release` inside the installed `oh-my-codex` package so `omx explore`, `omx sparkshell`, and runtime helpers do not need first-use Rust builds in a fresh container.
- Korean UTF-8 locale and tmux clipboard/mouse configuration.
- `bootstrap-dev-env` in `/usr/local/bin` so the health check is available even when `/workspace` is empty.

## Workspace model

- `/workspace`: container-local working directory. Do normal coding and Git work here.
- `/shared`: host-mounted file exchange directory backed by `./shared`. Use it only when you intentionally want files visible to the host GUI or want to copy artifacts out.
- `./shared` is ignored by Git in this repo.
- Container-local files, caches, login state, and `/workspace` contents disappear when the container is removed, so push important work to GitHub.

If you use Podman on an SELinux host and get permission errors on the scratch mount, change it to:

```yaml
volumes:
  - ./shared:/shared:Z
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

- `Containerfile` = reproducible image setup.
- `compose.yml` = container runtime plus host file exchange mount.
- Work in `/workspace`; use `/shared` only for deliberate host exchange.
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
