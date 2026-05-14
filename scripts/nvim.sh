#!/bin/bash
set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Linking Neovim config..."
ln -sf "$DOTFILES/nvim" "$HOME/.config/nvim"

echo "==> Linking formatter configs..."
ln -sf "$DOTFILES/uncrustify.cfg" "$HOME/.uncrustify.cfg"

echo "==> Neovim done. Launch nvim to let lazy.nvim bootstrap plugins."
