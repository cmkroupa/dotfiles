#!/usr/bin/env bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$DOTFILES"

source "$DOTFILES/lib/groups.sh"

STOW_OPTS=(--ignore='packages.*\.txt' --ignore='install\.sh')

if [[ -t 0 ]]; then
  mapfile -t selected_groups < <(
    printf '%s\n' "${PKG_GROUP_ORDER[@]}" \
      | fzf --multi \
            --prompt="link > " \
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
  BAK_DIR="$(pwd)/.bak/$pkg"

  conflicts=$(stow --simulate --target="$HOME" "${STOW_OPTS[@]}" "$pkg" 2>&1 \
    | grep -E "existing target is (not owned by stow|neither a link nor a directory)" || true)
  while IFS= read -r line; do
    target=$(echo "$line" | sed -E 's/.*existing target is (not owned by stow|neither a link nor a directory): //')
    [[ -z "$target" ]] && continue
    mkdir -p "$(dirname "$BAK_DIR/$target")"
    mv "$HOME/$target" "$BAK_DIR/$target" && echo "  backed up: ~/$target -> .bak/$pkg/$target"
  done <<< "$conflicts"

  stow --target="$HOME" "${STOW_OPTS[@]}" "$pkg" && echo "  stowed: $pkg"
done
