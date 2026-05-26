#!/bin/bash
set -e

echo "==> Installing language runtimes via mise..."
export PATH="$HOME/.local/bin:$PATH"
if ! command -v mise &>/dev/null; then
  echo "  mise not found — installing..."
  curl https://mise.run | sh
  export PATH="$HOME/.local/share/mise/bin:$PATH"
fi
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
(cd "$DOTFILES" && mise install)

echo "==> Runtimes done."
