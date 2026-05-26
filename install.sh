#!/usr/bin/env bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

if ! command -v stow &>/dev/null; then
  echo "Error: GNU stow required."
  echo "  Ubuntu/Debian: sudo apt install stow"
  echo "  macOS:         brew install stow"
  exit 1
fi

PACKAGES=(shell zsh bash tmux starship nvim)

# ── Package manager detection ──────────────────────────────────────────────────
if command -v brew &>/dev/null; then
  PM=brew
elif command -v apt &>/dev/null; then
  PM=apt
elif command -v pacman &>/dev/null; then
  PM=pacman
elif command -v dnf &>/dev/null; then
  PM=dnf
else
  PM=none
fi

install_pkgs() {
  case "$PM" in
    brew)   brew install "$@" ;;
    apt)    sudo apt install -y "$@" ;;
    pacman) sudo pacman -S --noconfirm "$@" ;;
    dnf)    sudo dnf install -y "$@" ;;
    none)   echo "  Warning: no supported package manager found. Install manually: $*" ;;
  esac
}

# ── Collect packages for detected PM ──────────────────────────────────────────
pkgs=()
for pkg in "${PACKAGES[@]}"; do
  file="$pkg/packages.$PM.txt"
  [[ -f "$file" ]] || file="$pkg/packages.txt"
  [[ -f "$file" ]] || continue
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == "#"* ]] && continue
    pkgs+=("$line")
  done < "$file"
done

if [[ ${#pkgs[@]} -gt 0 ]]; then
  echo "Installing packages via $PM: ${pkgs[*]}"
  install_pkgs "${pkgs[@]}"
  echo ""
fi

# ── Stow with conflict handling ────────────────────────────────────────────────
safe_stow() {
  local pkg="$1"
  local conflicts
  conflicts=$(stow --simulate --target="$HOME" "$pkg" 2>&1 | grep "existing target" || true)

  if [[ -n "$conflicts" ]]; then
    while IFS= read -r line; do
      local target
      target=$(echo "$line" | sed 's/.*existing target is not owned by stow: //')
      [[ -z "$target" ]] && continue
      echo "  backing up: ~/$target"
      mv "$HOME/$target" "$HOME/$target.bak"
    done <<< "$conflicts"
  fi

  stow --target="$HOME" "$pkg"
  echo "  stowed: $pkg"
}

for pkg in "${PACKAGES[@]}"; do
  safe_stow "$pkg"
done

echo ""
echo "Done. Run: source ~/.zshrc"
