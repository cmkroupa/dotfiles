#!/usr/bin/env bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v stow &>/dev/null; then
  echo "Error: GNU stow required. Install it first."
  echo "  Ubuntu/Debian: sudo apt install stow"
  exit 1
fi

PACKAGES=(zsh tmux starship nvim)

for pkg in "${PACKAGES[@]}"; do
  stow --target="$HOME" "$pkg"
  echo "  stowed: $pkg"
done

echo ""
echo "Done. Run: source ~/.zshrc"
