#!/usr/bin/env bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

PACKAGES=(shell zsh bash tmux starship nvim mise)
STOW_IGNORE=(--ignore='packages.*\.txt' --ignore='install\.sh')
BAK_DIR="$(pwd)/.bak"

for pkg in "${PACKAGES[@]}"; do
  stow -D --target="$HOME" "${STOW_IGNORE[@]}" "$pkg"
  echo "  unlinked: $pkg"
done

echo ""

if [[ -d "$BAK_DIR" ]]; then
  while IFS= read -r -d '' file; do
    rel="${file#$BAK_DIR/}"
    dest="$HOME/$rel"
    mkdir -p "$(dirname "$dest")"
    mv "$file" "$dest"
    echo "  restored: ~/$rel"
  done < <(find "$BAK_DIR" -type f -print0)
  rm -rf "$BAK_DIR"
else
  echo "  no backups to restore"
fi

echo ""
echo "Done."
