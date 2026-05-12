#!/bin/bash
set -e

DOTFILES="$HOME/dotfiles"

# ── Detect OS ─────────────────────────────────────────────────────────────────
if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="mac"
elif [[ -f /etc/arch-release ]]; then
  OS="arch"
elif grep -qi "ubuntu\|debian" /etc/os-release 2>/dev/null; then
  OS="ubuntu"
else
  echo "Unsupported OS. Supported: macOS, Ubuntu, Arch Linux."
  exit 1
fi
echo "Detected: $OS"

# ── Install ───────────────────────────────────────────────────────────────────

install_mac() {
  if ! command -v brew &>/dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/opt/homebrew/bin/brew shellenv)"
  fi
  brew install neovim git lazygit tmux fzf ripgrep eza zoxide mise \
               zsh-syntax-highlighting zsh-autosuggestions starship
  brew install --cask ghostty font-jetbrains-mono-nerd-font
  # TPM (tmux plugin manager)
  [[ ! -d ~/.tmux/plugins/tpm ]] \
    && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

install_arch() {
  sudo pacman -Syu --noconfirm
  sudo pacman -S --noconfirm --needed \
    neovim git lazygit tmux fzf ripgrep eza zoxide mise \
    zsh-syntax-highlighting zsh-autosuggestions starship \
    ttf-jetbrains-mono-nerd ghostty
  [[ ! -d ~/.tmux/plugins/tpm ]] \
    && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
}

install_ubuntu() {
  sudo apt update
  sudo apt install -y git neovim tmux fzf ripgrep curl unzip zoxide
  curl https://mise.run | sh

  # lazygit
  LG=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
    | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
  curl -sLo /tmp/lazygit.tar.gz \
    "https://github.com/jesseduffield/lazygit/releases/download/v${LG}/lazygit_${LG}_Linux_x86_64.tar.gz"
  tar xf /tmp/lazygit.tar.gz -C /tmp lazygit && sudo install /tmp/lazygit /usr/local/bin

  # eza (apt on 23.10+, binary otherwise)
  sudo apt install -y eza 2>/dev/null || {
    EZ=$(curl -s "https://api.github.com/repos/eza-community/eza/releases/latest" \
      | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
    curl -sLo /tmp/eza.tar.gz \
      "https://github.com/eza-community/eza/releases/download/v${EZ}/eza_x86_64-unknown-linux-gnu.tar.gz"
    tar xf /tmp/eza.tar.gz -C /tmp && sudo install /tmp/eza /usr/local/bin
  }

  # starship
  curl -sS https://starship.rs/install.sh | sh -s -- --yes

  # TPM
  [[ ! -d ~/.tmux/plugins/tpm ]] \
    && git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

  # JetBrainsMono Nerd Font
  mkdir -p ~/.local/share/fonts
  curl -sLo /tmp/JetBrainsMono.zip \
    "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
  unzip -qo /tmp/JetBrainsMono.zip "*.ttf" -d ~/.local/share/fonts/JetBrainsMono
  fc-cache -f
}

case "$OS" in
  mac)    install_mac    ;;
  arch)   install_arch   ;;
  ubuntu) install_ubuntu ;;
esac

# ── Symlinks ──────────────────────────────────────────────────────────────────
echo "Setting up symlinks..."
mkdir -p "$HOME/.config/ghostty" "$DOTFILES/bin"

rm -rf "$HOME/.tmux.conf"
ln -sf "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"

if [[ "$OS" == "mac" ]]; then
  rm -rf "$HOME/.zshrc"
  ln -sf "$DOTFILES/.zshrc" "$HOME/.zshrc"
else
  rm -rf "$HOME/.bashrc"
  ln -sf "$DOTFILES/.bashrc" "$HOME/.bashrc"
fi

rm -rf "$HOME/.config/nvim" "$HOME/.config/ghostty/config" "$HOME/.config/starship.toml"
ln -sf "$DOTFILES/nvim"           "$HOME/.config/nvim"
ln -sf "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"
ln -sf "$DOTFILES/starship.toml"  "$HOME/.config/starship.toml"

[[ "$OS" == "mac" ]] \
  && echo "Done. Run: source ~/.zshrc" \
  || echo "Done. Run: source ~/.bashrc"
