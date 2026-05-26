#!/usr/bin/env bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

PACKAGES=(shell zsh bash tmux starship nvim mise)
STOW_IGNORE=(--ignore='packages.*\.txt' --ignore='install\.sh')
BACKUP_LOG="$(pwd)/.dotfiles-backups"

for pkg in "${PACKAGES[@]}"; do
  stow -D --target="$HOME" "${STOW_IGNORE[@]}" "$pkg"
  echo "  unlinked: $pkg"
done

echo ""

if [[ -f "$BACKUP_LOG" && -s "$BACKUP_LOG" ]]; then
  while IFS= read -r original; do
    [[ -f "${original}.bak" ]] || continue
    mv "${original}.bak" "$original"
    echo "  restored: $original"
  done < "$BACKUP_LOG"
  rm "$BACKUP_LOG"
else
  echo "  no backups to restore"
fi

echo ""
echo "Done."
