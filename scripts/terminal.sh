#!/bin/bash
set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES/scripts/lib/detect_os.sh"

echo "==> Linking terminal configs..."

mkdir -p "$HOME/.config/ghostty" "$HOME/.config/mise"
ln -sf "$DOTFILES/.tmux.conf"     "$HOME/.tmux.conf"
ln -sf "$DOTFILES/ghostty/config" "$HOME/.config/ghostty/config"
ln -sf "$DOTFILES/starship.toml"  "$HOME/.config/starship.toml"
ln -sf "$DOTFILES/mise.toml"      "$HOME/.config/mise/config.toml"

# TPM
if [[ ! -d ~/.tmux/plugins/tpm ]]; then
  echo "==> Installing TPM..."
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Shell rc injection
if [[ "$SHELL" == *"zsh"* ]] || [[ "$OS" == "mac" ]]; then
  CONF_FILE="$HOME/.zshrc"
  INIT_CMDS=("source $DOTFILES/.zshrc")
else
  CONF_FILE="$HOME/.bashrc"
  INIT_CMDS=(
    "eval \"\$($HOME/.local/bin/mise activate bash)\""
    "eval \"\$(zoxide init bash --cmd cd)\""
    "eval \"\$(starship init bash)\""
    "source $DOTFILES/command_aliases"
  )
fi

# Restore default if current file is a broken symlink
if [[ -L "$CONF_FILE" ]]; then
  echo "Fixing broken symlink at $CONF_FILE..."
  rm "$CONF_FILE"
  if [[ "$OS" == "mac" ]]; then
    touch "$HOME/.zshrc"
  else
    cp /etc/skel/.bashrc "$HOME/.bashrc"
  fi
fi

echo "==> Injecting shell init into $CONF_FILE..."
for cmd in "${INIT_CMDS[@]}"; do
  grep -qF "$cmd" "$CONF_FILE" 2>/dev/null || echo "$cmd" >> "$CONF_FILE"
done

touch "$HOME/.hushlogin"
echo "==> Terminal done. Reload shell: source $CONF_FILE"
