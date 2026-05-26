#!/usr/bin/env bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v stow &>/dev/null; then
  echo "Error: GNU stow required."
  echo "  Ubuntu/Debian: sudo apt install stow"
  exit 1
fi

PACKAGES=(shell zsh bash tmux starship nvim)

# Collect apt packages from each module's packages.txt
pkgs=()
for pkg in "${PACKAGES[@]}"; do
  [[ -f "$pkg/packages.txt" ]] || continue
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == "#"* ]] && continue
    pkgs+=("$line")
  done < "$pkg/packages.txt"
done

if [[ ${#pkgs[@]} -gt 0 ]]; then
  echo "Installing packages: ${pkgs[*]}"
  sudo apt install -y "${pkgs[@]}"
  echo ""
fi

# Stow each module
for pkg in "${PACKAGES[@]}"; do
  stow --target="$HOME" "$pkg"
  echo "  stowed: $pkg"
done

echo ""
echo "Done. Run: source ~/.zshrc"
