#!/usr/bin/env bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

PACKAGES=(shell zsh bash tmux starship nvim mise)
STOW_OPTS=(--ignore='packages.*\.txt' --ignore='install\.sh')
BAK_DIR="$(pwd)/.bak"

for pkg in "${PACKAGES[@]}"; do
  stow -D --target="$HOME" "${STOW_OPTS[@]}" "$pkg" && echo "  unlinked: $pkg"
done

if [[ -d "$BAK_DIR" ]]; then
  while IFS= read -r -d '' f; do
    rel="${f#$BAK_DIR/}"; dest="$HOME/$rel"
    mkdir -p "$(dirname "$dest")"
    mv "$f" "$dest" && echo "  restored: ~/$rel"
  done < <(find "$BAK_DIR" -type f -print0)
  rm -rf "$BAK_DIR"
else
  echo "  no backups to restore"
fi

echo "Done."
