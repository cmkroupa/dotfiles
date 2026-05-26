#!/bin/bash
set -e
DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES/scripts/lib/detect_os.sh"

# Only remove a symlink if it points into our dotfiles repo
remove_link() {
  local target="$1"
  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$DOTFILES"* ]]; then
    rm "$target"
    echo "  removed $target"
  fi
}

# Remove each fixed string from a file in-place
remove_injected_lines() {
  local conf_file="$1"; shift
  [[ -f "$conf_file" ]] || return
  local tmp; tmp=$(mktemp)
  cp "$conf_file" "$tmp"
  for line in "$@"; do
    grep -vF "$line" "$tmp" > "${tmp}.new" && mv "${tmp}.new" "$tmp"
  done
  cp "$tmp" "$conf_file"
  rm "$tmp"
}

echo "==> Removing injected shell init..."
if [[ "$OS" == "mac" ]]; then
  CONF_FILE="$HOME/.zshrc"
  remove_injected_lines "$CONF_FILE" \
    "source $DOTFILES/config/zshrc"
else
  CONF_FILE="$HOME/.bashrc"
  remove_injected_lines "$CONF_FILE" \
    "source $DOTFILES/config/aliases" \
    "command -v mise     &>/dev/null && eval \"\$(mise activate bash)\"" \
    "command -v zoxide   &>/dev/null && eval \"\$(zoxide init bash --cmd cd)\"" \
    "command -v starship &>/dev/null && eval \"\$(starship init bash)\"" \
    "[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash || true"
fi
echo "  cleaned $CONF_FILE"

if [[ -f "$HOME/.hushlogin" ]]; then
  rm "$HOME/.hushlogin"
  echo "  removed ~/.hushlogin"
fi

echo "==> Terminal undo done."
