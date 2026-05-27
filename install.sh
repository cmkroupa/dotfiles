#!/usr/bin/env bash
set -e

cd "$(dirname "${BASH_SOURCE[0]}")"

source "$(dirname "${BASH_SOURCE[0]}")/lib/groups.sh"

PACKAGES=()
for g in "${PKG_GROUP_ORDER[@]}"; do
  read -ra _pkgs <<< "${PKG_GROUPS[$g]}"
  PACKAGES+=("${_pkgs[@]}")
done

[[ "$(uname)" == "Darwin" ]] && OS=macOS || OS=$(. /etc/os-release 2>/dev/null && echo "$NAME" || echo unknown)
if   command -v brew   &>/dev/null; then PM=brew
elif command -v apt    &>/dev/null; then PM=apt
elif command -v pacman &>/dev/null; then PM=pacman
elif command -v dnf    &>/dev/null; then PM=dnf
else PM=none
fi

echo "OS: $OS  |  PM: $PM"

_conflicts=()
{ command -v pyenv &>/dev/null || [[ -d "$HOME/.pyenv" ]]; }                                          && _conflicts+=(pyenv)
{ command -v conda &>/dev/null || [[ -d "$HOME/miniconda3" ]] || [[ -d "$HOME/anaconda3" ]]; }        && _conflicts+=(conda)
{ [[ -d "$HOME/.nvm" ]] || [[ -n "${NVM_DIR:-}" ]]; }                                                 && _conflicts+=(nvm)
{ command -v asdf &>/dev/null || [[ -d "$HOME/.asdf" ]]; }                                            && _conflicts+=(asdf)
{ command -v rbenv &>/dev/null || [[ -d "$HOME/.rbenv" ]]; }                                          && _conflicts+=(rbenv)
{ command -v rvm &>/dev/null || [[ -d "$HOME/.rvm" ]]; }                                              && _conflicts+=(rvm)
if [[ ${#_conflicts[@]} -gt 0 ]]; then
  echo "Error: conflicting runtime managers detected: ${_conflicts[*]}"
  echo "  Remove them before installing, or activate tools in ~/.config/mise/config.toml instead."
  exit 1
fi

if ! command -v stow &>/dev/null; then
  case "$PM" in
    apt) cmd="sudo apt install stow" ;; brew) cmd="brew install stow" ;;
    pacman) cmd="sudo pacman -S stow" ;; dnf) cmd="sudo dnf install stow" ;;
    *) cmd="install stow via your package manager" ;;
  esac
  echo "Error: stow required — $cmd"; exit 1
fi

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

bash "$(dirname "${BASH_SOURCE[0]}")/lib/link.sh"

case "$SHELL" in
  */zsh)  rc=~/.zshrc ;;
  */bash) rc=~/.bashrc ;;
  *)      rc="your shell's rc file" ;;
esac
echo "Done. Run: source $rc"
