#!/usr/bin/env bash
set -euo pipefail

echo "== tool versions =="
node -v
cargo --version
rustc --version
rustup --version
tmux -V
gh --version | head -n 1
codex --version
omx --version

echo "== OMX health =="
omx doctor

echo "== auth status =="
gh auth status || true

echo
cat <<'MSG'
Bootstrap check complete.

This environment intentionally uses no persistent volumes. If this is a fresh
container, run the login steps again when needed:

  codex --login
  gh auth login

Non-secret OMX setup and Rust native helper builds are baked into the image.
MSG
