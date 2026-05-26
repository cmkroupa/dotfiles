#!/bin/bash
set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

remove_link() {
  local target="$1"
  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$DOTFILES"* ]]; then
    rm "$target"
    echo "  removed $target"
  fi
}

echo "==> Removing Neovim config link..."
NVIM_DIR="$HOME/.config/nvim"
remove_link "$NVIM_DIR"

if [[ -d "$NVIM_DIR.bak" ]]; then
  mv "$NVIM_DIR.bak" "$NVIM_DIR"
  echo "  restored $NVIM_DIR from backup"
fi

echo "==> Removing formatter config link..."
remove_link "$HOME/.uncrustify.cfg"

echo "==> Neovim undo done."
