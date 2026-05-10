#!/usr/bin/env bash
set -euo pipefail

echo "== tool versions =="
node -v
cargo --version
rustc --version
rustup --version 2>/dev/null || echo "rustup not found; rebuild the image to use the baked rustup toolchain"
tmux -V
gh --version | head -n 1
codex --version
omx --version

echo "== npm latest checks =="
installed_codex="$(codex --version | awk '{print $2}')"
latest_codex="$(npm view @openai/codex version 2>/dev/null || true)"
printf '@openai/codex installed: %s\n' "${installed_codex:-unknown}"
printf '@openai/codex npm latest: %s\n' "${latest_codex:-unknown}"
if [ -n "${latest_codex}" ] && [ "${installed_codex}" != "${latest_codex}" ]; then
  echo "WARNING: Codex CLI is not npm latest; rebuild the image to refresh it."
fi

echo "== OMX non-secret config refresh =="
if command -v configure-codex-omx >/dev/null 2>&1; then
  configure-codex-omx
else
  "$(dirname "$0")/configure-codex-omx.sh"
fi

CODEX_CONFIG="${CODEX_HOME:-/root/.codex}/config.toml"
echo "== Codex / OMX baked defaults =="
grep -E "^(suppress_unstable_features_warning|model|model_reasoning_effort|service_tier) =" "$CODEX_CONFIG" || true
grep -A2 "^\[tui\]" "$CODEX_CONFIG" || true

echo "== auth status =="
gh auth status || true

echo
cat <<'MSG'
Bootstrap check complete.

This environment intentionally uses no persistent volumes. If this is a fresh
container, run the login steps again when needed:

  codex --login
  gh auth login

Non-secret Codex/OMX setup, warning suppression, HUD defaults, and Rust native helper builds are baked into the image. Re-running this bootstrap script refreshes those non-secret settings without touching login state.
MSG
