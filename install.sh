#!/usr/bin/env bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

PACKAGES=(shell zsh bash tmux starship nvim mise)
STOW_IGNORE=(--ignore='packages.*\.txt' --ignore='install\.sh')

# ── OS detection ───────────────────────────────────────────────────────────────
if [[ "$(uname)" == "Darwin" ]]; then
  OS=macOS
elif [[ -f /etc/os-release ]]; then
  OS=$(. /etc/os-release && echo "$NAME")
else
  OS=unknown
fi

echo "Detected OS: $OS"

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

echo "Detected package manager: $PM"
echo ""

if ! command -v stow &>/dev/null; then
  echo "Error: GNU stow required."
  case "$PM" in
    apt)    echo "  Run: sudo apt install stow" ;;
    brew)   echo "  Run: brew install stow" ;;
    pacman) echo "  Run: sudo pacman -S stow" ;;
    dnf)    echo "  Run: sudo dnf install stow" ;;
    *)      echo "  Install stow via your package manager." ;;
  esac
  exit 1
fi

# ── Package installer ──────────────────────────────────────────────────────────
install_pkgs() {
  case "$PM" in
    brew)   brew install "$@" ;;
    apt)    sudo apt install -y "$@" ;;
    pacman) sudo pacman -S --noconfirm "$@" ;;
    dnf)    sudo dnf install -y "$@" ;;
    none)   echo "  Warning: no package manager found. Install manually: $*" ;;
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
  echo "Installing packages: ${pkgs[*]}"
  install_pkgs "${pkgs[@]}"
  echo ""
fi

# ── Per-module custom installers ───────────────────────────────────────────────
for pkg in "${PACKAGES[@]}"; do
  [[ -f "$pkg/install.sh" ]] || continue
  echo "Running $pkg installer..."
  bash "$pkg/install.sh"
done

echo ""

# ── Stow with conflict handling ────────────────────────────────────────────────
safe_stow() {
  local pkg="$1"
  local conflicts
  conflicts=$(stow --simulate --target="$HOME" "${STOW_IGNORE[@]}" "$pkg" 2>&1 \
    | grep -E "existing target is (not owned by stow|neither a link nor a directory)" || true)

  if [[ -n "$conflicts" ]]; then
    while IFS= read -r line; do
      local target
      target=$(echo "$line" | sed -E 's/.*existing target is (not owned by stow|neither a link nor a directory): //')
      [[ -z "$target" ]] && continue
      echo "  backing up: ~/$target"
      mv "$HOME/$target" "$HOME/$target.bak"
    done <<< "$conflicts"
  fi

  stow --target="$HOME" "${STOW_IGNORE[@]}" "$pkg"
  echo "  stowed: $pkg"
}

for pkg in "${PACKAGES[@]}"; do
  safe_stow "$pkg"
done

echo ""
echo "Done. Run: source ~/.zshrc"
