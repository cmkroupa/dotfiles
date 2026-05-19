#!/bin/bash
set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Linking Neovim config..."

NVIM_DIR="$HOME/.config/nvim"
# ln -sf won't replace a real directory — back it up first
if [[ -d "$NVIM_DIR" && ! -L "$NVIM_DIR" ]]; then
  echo "  Backing up existing nvim config to $NVIM_DIR.bak..."
  mv "$NVIM_DIR" "$NVIM_DIR.bak"
fi
ln -sfn "$DOTFILES/nvim" "$NVIM_DIR"

echo "==> Linking formatter configs..."
ln -sf "$DOTFILES/uncrustify.cfg" "$HOME/.uncrustify.cfg"

echo "==> Clearing stale Mason Ruby packages (will reinstall on next nvim launch)..."
rm -rf \
  "$HOME/.local/share/nvim/mason/packages/rubocop" \
  "$HOME/.local/share/nvim/mason/packages/ruby-lsp" \
  "$HOME/.local/share/nvim/mason/bin/rubocop" \
  "$HOME/.local/share/nvim/mason/bin/ruby-lsp"

echo "==> Neovim done. Launch nvim to let lazy.nvim bootstrap plugins."
