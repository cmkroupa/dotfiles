#!/bin/bash
set -e

echo "==> Installing language runtimes via mise..."
export PATH="$HOME/.local/bin:$PATH"
if ! command -v mise &>/dev/null; then
  echo "mise not found — run setup.sh --packages first."
  exit 1
fi
mise install

echo "==> Installing global npm tools..."
export PATH="$HOME/.local/share/mise/shims:$PATH"
if command -v npm &>/dev/null; then
  npm install -g tldr
fi

echo "==> Installing opencode..."
if ! command -v opencode &>/dev/null; then
  curl -fsSL https://opencode.ai/install | bash
fi

echo "==> Runtimes done."
