#!/bin/bash
set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES/scripts/lib/detect_os.sh"

echo "==> Installing packages..."

case "$OS" in
  mac)
    if ! command -v brew &>/dev/null; then
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
    brew install neovim git lazygit tmux fzf ripgrep eza zoxide mise \
                 zsh-syntax-highlighting zsh-autosuggestions starship uncrustify
    brew install --cask ghostty font-jetbrains-mono-nerd-font
    ;;

  arch)
    sudo pacman -Syu --noconfirm
    sudo pacman -S --noconfirm --needed \
      neovim git lazygit tmux fzf ripgrep eza zoxide mise \
      zsh-syntax-highlighting zsh-autosuggestions starship \
      ttf-jetbrains-mono-nerd ghostty \
      base-devel clang uncrustify
    ;;

  ubuntu)
    sudo apt update
    sudo apt install -y git tmux fzf ripgrep curl unzip wget zoxide \
      build-essential clang uncrustify \
      libyaml-dev libssl-dev libreadline-dev libffi-dev zlib1g-dev libgdbm-dev

    curl https://mise.run | sh

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

    # eza (apt on 23.10+, binary fallback otherwise)
    sudo apt install -y eza 2>/dev/null || {
      EZ=$(curl -s "https://api.github.com/repos/eza-community/eza/releases/latest" \
        | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
      curl -sLo /tmp/eza.tar.gz \
        "https://github.com/eza-community/eza/releases/download/v${EZ}/eza_x86_64-unknown-linux-gnu.tar.gz"
      tar xf /tmp/eza.tar.gz -C /tmp
      sudo install /tmp/eza /usr/local/bin
    }

    # starship
    curl -sS https://starship.rs/install.sh | sh -s -- --yes

    # JetBrainsMono Nerd Font
    mkdir -p ~/.local/share/fonts
    curl -sLo /tmp/JetBrainsMono.zip \
      "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
    unzip -qo /tmp/JetBrainsMono.zip "*.ttf" -d ~/.local/share/fonts/JetBrainsMono
    fc-cache -f
    ;;
esac

echo "==> Packages done."
