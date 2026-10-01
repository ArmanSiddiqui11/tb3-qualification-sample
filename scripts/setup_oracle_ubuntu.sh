#!/usr/bin/env bash
set -euo pipefail

# Installs local prerequisites needed to run:
#   harbor run --path <repo> --agent oracle
# on Ubuntu/Debian hosts.

if ! command -v sudo >/dev/null 2>&1; then
  echo "sudo is required for apt-based setup." >&2
  exit 1
fi

sudo apt-get update
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y \
  ca-certificates \
  curl \
  docker.io \
  docker-compose-v2

if command -v systemctl >/dev/null 2>&1; then
  sudo systemctl enable docker >/dev/null 2>&1 || true
  sudo systemctl start docker >/dev/null 2>&1 || true
fi

if [ ! -x "${HOME}/.local/bin/uv" ]; then
  curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# shellcheck source=/dev/null
if [ -f "${HOME}/.local/bin/env" ]; then
  # Add uv and harbor to PATH for the current shell.
  source "${HOME}/.local/bin/env"
fi

if ! command -v harbor >/dev/null 2>&1; then
  uv tool install harbor
fi

echo
echo "Setup complete."
echo "Validate with:"
echo "  docker compose version"
echo "  harbor --help"
echo
echo "Run oracle from the repo root (required: 3 runs):"
echo "  harbor run --path . --agent oracle --n-concurrent 1 -k 3 -o jobs-local/oracle-run"
echo
echo "Run NOP sanity check:"
echo "  harbor run --path . --agent nop --n-concurrent 1 -o jobs-local/nop-run"
