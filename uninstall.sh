#!/usr/bin/env bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

source "$(dirname "${BASH_SOURCE[0]}")/lib/groups.sh"

STOW_OPTS=(--ignore='packages.*\.txt' --ignore='install\.sh')

if [[ -t 0 ]]; then
  mapfile -t selected_groups < <(
    printf '%s\n' "${PKG_GROUP_ORDER[@]}" \
      | fzf --multi \
            --prompt="unlink > " \
            --header="x/tab: toggle  ctrl-a: all  enter: confirm" \
            --bind 'x:toggle,ctrl-a:toggle-all'
  )
  [[ ${#selected_groups[@]} -eq 0 ]] && { echo "Nothing selected."; exit 0; }
else
  selected_groups=("${PKG_GROUP_ORDER[@]}")
fi

pkgs=()
for g in "${selected_groups[@]}"; do
  read -ra _pkgs <<< "${PKG_GROUPS[$g]}"
  pkgs+=("${_pkgs[@]}")
done

for pkg in "${pkgs[@]}"; do
  if stow -D --target="$HOME" "${STOW_OPTS[@]}" "$pkg" 2>/dev/null; then
    echo "  unlinked: $pkg"
  else
    echo "  (not linked: $pkg)"
  fi

  BAK_DIR="$(pwd)/.bak/$pkg"
  if [[ -d "$BAK_DIR" ]]; then
    while IFS= read -r -d '' f; do
      rel="${f#$BAK_DIR/}"; dest="$HOME/$rel"
      mkdir -p "$(dirname "$dest")"
      mv "$f" "$dest" && echo "  restored: ~/$rel"
    done < <(find "$BAK_DIR" -type f -print0)
    rm -rf "$BAK_DIR"
  fi
done

echo "Done."
