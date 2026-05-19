#!/bin/bash
set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES/scripts/lib/detect_os.sh"

echo "==> Linking terminal configs..."

mkdir -p "$HOME/.config/mise"
ln -sf "$DOTFILES/.tmux.conf"    "$HOME/.tmux.conf"
ln -sf "$DOTFILES/starship.toml" "$HOME/.config/starship.toml"
ln -sf "$DOTFILES/mise.toml"     "$HOME/.config/mise/config.toml"

# Ghostty: skip if Omarchy is installed — it manages ghostty/config and rewrites it on theme changes
if [[ -d "$HOME/.config/omarchy" ]]; then
  echo "  Omarchy detected — skipping ghostty config (Omarchy manages it)"
else
  mkdir -p "$HOME/.config/ghostty"
  ln -sf "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"

  echo "==> Writing ghostty platform config..."
  PLATFORM_CONF="$HOME/.config/ghostty/platform.conf"
  if [[ "$OS" == "mac" ]]; then
    cat > "$PLATFORM_CONF" <<'EOF'
macos-option-as-alt = true
EOF
  else
    cat > "$PLATFORM_CONF" <<'EOF'
gtk-toolbar-style = flat

# Fix general slowness on Hyprland (https://github.com/ghostty-org/ghostty/discussions/3224)
async-backend = epoll
EOF
  fi
fi

# TPM
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  echo "==> Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Shell rc injection — zsh on macOS, bash on Linux
if [[ "$OS" == "mac" ]]; then
  CONF_FILE="$HOME/.zshrc"
  INIT_CMDS=("source $DOTFILES/.zshrc")
else
  CONF_FILE="$HOME/.bashrc"
  INIT_CMDS=(
    "source $DOTFILES/command_aliases"
    "command -v mise     &>/dev/null && eval \"\$(mise activate bash)\""
    "command -v zoxide   &>/dev/null && eval \"\$(zoxide init bash --cmd cd)\""
    "command -v starship &>/dev/null && eval \"\$(starship init bash)\""
    "[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash || true"
  )
fi

# Replace broken symlink with an empty file
if [[ -L "$CONF_FILE" && ! -e "$CONF_FILE" ]]; then
  echo "  Replacing broken symlink at $CONF_FILE..."
  rm "$CONF_FILE"
fi
[[ -f "$CONF_FILE" ]] || touch "$CONF_FILE"

echo "==> Injecting shell init into $CONF_FILE..."
for cmd in "${INIT_CMDS[@]}"; do
  grep -qF "$cmd" "$CONF_FILE" || echo "$cmd" >> "$CONF_FILE"
done

touch "$HOME/.hushlogin"
echo "==> Terminal done. Reload shell: source $CONF_FILE"
