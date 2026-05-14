#!/bin/bash
set -e

echo "==> Installing language runtimes via mise..."
export PATH="$HOME/.local/bin:$PATH"
if ! command -v mise &>/dev/null; then
  echo "mise not found — run setup.sh --packages first."
  exit 1
fi
mise install
echo "==> Runtimes done."
