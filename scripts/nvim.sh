#!/bin/bash
set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES/scripts/lib/detect_os.sh"

echo "==> Installing Neovim packages..."

case "$OS" in
  mac)
    brew install neovim git lazygit ripgrep uncrustify
    ;;

  arch)
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm --needed neovim git lazygit ripgrep base-devel uncrustify
    ;;

  ubuntu)
    sudo apt update
    sudo apt install -y git build-essential ripgrep uncrustify

    # neovim (apt version is outdated; vim.lsp.config API requires 0.11+)
    NVIM_VER=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" \
      | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
    curl -sLo /tmp/nvim.tar.gz \
      "https://github.com/neovim/neovim/releases/download/v${NVIM_VER}/nvim-linux-x86_64.tar.gz"
    sudo tar xf /tmp/nvim.tar.gz -C /opt
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

    # lazygit
    LG=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
      | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
    curl -sLo /tmp/lazygit.tar.gz \
      "https://github.com/jesseduffield/lazygit/releases/download/v${LG}/lazygit_${LG}_Linux_x86_64.tar.gz"
    tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
    sudo install /tmp/lazygit /usr/local/bin
    ;;
esac

echo "==> Linking Neovim config..."

NVIM_DIR="$HOME/.config/nvim"
# ln -sf won't replace a real directory — back it up first
if [[ -d "$NVIM_DIR" && ! -L "$NVIM_DIR" ]]; then
  echo "  Backing up existing nvim config to $NVIM_DIR.bak..."
  mv "$NVIM_DIR" "$NVIM_DIR.bak"
fi
ln -sfn "$DOTFILES/nvim" "$NVIM_DIR"

echo "==> Linking formatter configs..."
ln -sf "$DOTFILES/config/uncrustify.cfg" "$HOME/.uncrustify.cfg"

echo "==> Clearing stale Mason Ruby packages (will reinstall on next nvim launch)..."
rm -rf \
  "$HOME/.local/share/nvim/mason/packages/rubocop" \
  "$HOME/.local/share/nvim/mason/packages/ruby-lsp" \
  "$HOME/.local/share/nvim/mason/bin/rubocop" \
  "$HOME/.local/share/nvim/mason/bin/ruby-lsp"

echo "==> Neovim done. Launch nvim to let lazy.nvim bootstrap plugins."
echo ""
echo "  Useful aliases (available after: source ~/.bashrc)"
echo "    reload              reload shell config"
echo "    lspinit [path]      init clangd LSP: generates compile_commands.json via dry-run (no build needed)"
echo "                        run from root of project"
