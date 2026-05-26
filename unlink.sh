#!/usr/bin/env bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

PACKAGES=(shell zsh bash tmux starship nvim mise)
STOW_IGNORE=(--ignore='packages.*\.txt' --ignore='install\.sh')

for pkg in "${PACKAGES[@]}"; do
  stow -D --target="$HOME" "${STOW_IGNORE[@]}" "$pkg"
  echo "  unlinked: $pkg"
done

echo ""
echo "Done. Symlinks removed — original .bak files (if any) were not restored."
