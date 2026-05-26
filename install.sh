#!/usr/bin/env bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

PACKAGES=(shell zsh bash tmux starship nvim mise)
STOW_OPTS=(--ignore='packages.*\.txt' --ignore='install\.sh')
BAK_DIR="$(pwd)/.bak"

[[ "$(uname)" == "Darwin" ]] && OS=macOS || OS=$(. /etc/os-release 2>/dev/null && echo "$NAME" || echo unknown)
command -v brew   &>/dev/null && PM=brew   ||
command -v apt    &>/dev/null && PM=apt    ||
command -v pacman &>/dev/null && PM=pacman ||
command -v dnf    &>/dev/null && PM=dnf    || PM=none

echo "OS: $OS  |  PM: $PM"

if ! command -v stow &>/dev/null; then
  case "$PM" in
    apt) cmd="sudo apt install stow" ;; brew) cmd="brew install stow" ;;
    pacman) cmd="sudo pacman -S stow" ;; dnf) cmd="sudo dnf install stow" ;;
    *) cmd="install stow via your package manager" ;;
  esac
  echo "Error: stow required — $cmd"; exit 1
fi

[[ -d "$BAK_DIR" ]] && { echo "Error: .bak/ exists — run ./unlink.sh first"; exit 1; }

pkgs=()
for pkg in "${PACKAGES[@]}"; do
  f="$pkg/packages.$PM.txt"; [[ -f "$f" ]] || f="$pkg/packages.txt"
  [[ -f "$f" ]] || continue
  while IFS= read -r line; do
    [[ -z "$line" || "$line" == "#"* ]] || pkgs+=("$line")
  done < "$f"
done

if [[ ${#pkgs[@]} -gt 0 ]]; then
  case "$PM" in
    brew)   brew install "${pkgs[@]}" ;;
    apt)    sudo apt install -y "${pkgs[@]}" ;;
    pacman) sudo pacman -S --noconfirm "${pkgs[@]}" ;;
    dnf)    sudo dnf install -y "${pkgs[@]}" ;;
    none)   echo "No package manager — install manually: ${pkgs[*]}" ;;
  esac
fi

for pkg in "${PACKAGES[@]}"; do
  [[ -f "$pkg/install.sh" ]] && bash "$pkg/install.sh"
done

for pkg in "${PACKAGES[@]}"; do
  conflicts=$(stow --simulate --target="$HOME" "${STOW_OPTS[@]}" "$pkg" 2>&1 \
    | grep -E "existing target is (not owned by stow|neither a link nor a directory)" || true)
  while IFS= read -r line; do
    target=$(echo "$line" | sed -E 's/.*existing target is (not owned by stow|neither a link nor a directory): //')
    [[ -z "$target" ]] && continue
    mkdir -p "$(dirname "$BAK_DIR/$target")"
    mv "$HOME/$target" "$BAK_DIR/$target" && echo "  backed up: ~/$target"
  done <<< "$conflicts"
  stow --target="$HOME" "${STOW_OPTS[@]}" "$pkg" && echo "  stowed: $pkg"
done

echo "Done. Run: source ~/.zshrc"
