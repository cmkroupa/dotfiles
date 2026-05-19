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
                 zsh-syntax-highlighting zsh-autosuggestions starship uncrustify \
                 btop bat fd dust gum jq fastfetch gh lazydocker
    brew install --cask ghostty font-jetbrains-mono-nerd-font
    ;;

  arch)
    sudo pacman -Syu --noconfirm
    sudo pacman -Rns --noconfirm tldr 2>/dev/null || true
    sudo pacman -S --noconfirm --needed \
      zsh neovim git lazygit tmux fzf ripgrep eza zoxide mise \
      zsh-syntax-highlighting zsh-autosuggestions starship \
      ttf-jetbrains-mono-nerd ghostty \
      base-devel clang uncrustify \
      btop bat fd dust gum jq tealdeer fastfetch github-cli
    if command -v yay &>/dev/null; then
      yay -S --noconfirm lazydocker
    fi
    ;;

  ubuntu)
    sudo apt update
    sudo apt install -y git zsh tmux fzf ripgrep curl unzip wget zoxide \
      zsh-syntax-highlighting zsh-autosuggestions \
      build-essential clang uncrustify \
      libyaml-dev libssl-dev libreadline-dev libffi-dev zlib1g-dev libgdbm-dev \
      btop bat fd-find jq

    # Ubuntu names bat→batcat and fd→fdfind; expose them under the normal names
    mkdir -p "$HOME/.local/bin"
    [[ -f /usr/bin/batcat ]] && ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
    [[ -f /usr/bin/fdfind ]] && ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"

    # gum (Charm apt repo)
    if ! command -v gum &>/dev/null; then
      sudo mkdir -p /etc/apt/keyrings
      curl -fsSL https://repo.charm.sh/apt/gpg.key \
        | sudo gpg --dearmor -o /etc/apt/keyrings/charm.gpg
      echo "deb [signed-by=/etc/apt/keyrings/charm.gpg] https://repo.charm.sh/apt/ * *" \
        | sudo tee /etc/apt/sources.list.d/charm.list
      sudo apt update && sudo apt install -y gum
    fi

    # gh (GitHub CLI apt repo)
    if ! command -v gh &>/dev/null; then
      curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
        | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
      echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list
      sudo apt update && sudo apt install -y gh
    fi

    # dust (binary from GitHub)
    if ! command -v dust &>/dev/null; then
      DUST=$(curl -s "https://api.github.com/repos/bootandy/dust/releases/latest" \
        | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
      curl -sLo /tmp/dust.tar.gz \
        "https://github.com/bootandy/dust/releases/download/v${DUST}/dust-v${DUST}-x86_64-unknown-linux-gnu.tar.gz"
      tar xf /tmp/dust.tar.gz -C /tmp
      sudo install "/tmp/dust-v${DUST}-x86_64-unknown-linux-gnu/dust" /usr/local/bin/
    fi

    # fastfetch (deb from GitHub)
    if ! command -v fastfetch &>/dev/null; then
      FF=$(curl -s "https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest" \
        | grep '"tag_name"' | sed 's/.*"\([^"]*\)".*/\1/')
      curl -sLo /tmp/fastfetch.deb \
        "https://github.com/fastfetch-cli/fastfetch/releases/download/${FF}/fastfetch-linux-amd64.deb"
      sudo dpkg -i /tmp/fastfetch.deb
    fi

    # lazydocker (binary from GitHub)
    if ! command -v lazydocker &>/dev/null; then
      LD=$(curl -s "https://api.github.com/repos/jesseduffield/lazydocker/releases/latest" \
        | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
      curl -sLo /tmp/lazydocker.tar.gz \
        "https://github.com/jesseduffield/lazydocker/releases/download/v${LD}/lazydocker_${LD}_Linux_x86_64.tar.gz"
      tar xf /tmp/lazydocker.tar.gz -C /tmp lazydocker
      sudo install /tmp/lazydocker /usr/local/bin/
    fi

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
