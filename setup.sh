#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$DOTFILES/scripts"

usage() {
  cat <<EOF
Usage: $(basename "$0") [flags]

Flags (combinable):
  --all        Run all setup steps
  --packages   Install system packages (brew/pacman/apt, neovim, fonts, etc.)
  --nvim       Link Neovim config + install language runtimes (node/python/ruby/go/rust)
  --terminal   Link tmux/ghostty/starship/mise configs, inject shell init, install TPM

  --help       Show this message

Examples:
  ./setup.sh --all
  ./setup.sh --packages --nvim
  ./setup.sh --terminal
EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

RUN_PACKAGES=0
RUN_NVIM=0
RUN_TERMINAL=0

for arg in "$@"; do
  case "$arg" in
    --all)      RUN_PACKAGES=1; RUN_NVIM=1; RUN_TERMINAL=1 ;;
    --packages) RUN_PACKAGES=1 ;;
    --nvim)     RUN_NVIM=1 ;;
    --terminal) RUN_TERMINAL=1 ;;
    --help|-h)  usage; exit 0 ;;
    *)          echo "Unknown flag: $arg"; usage; exit 1 ;;
  esac
done

[[ $RUN_PACKAGES -eq 1 ]] && bash "$SCRIPTS/packages.sh"
[[ $RUN_NVIM     -eq 1 ]] && bash "$SCRIPTS/nvim.sh" && bash "$SCRIPTS/runtimes.sh"
[[ $RUN_TERMINAL -eq 1 ]] && bash "$SCRIPTS/terminal.sh"

echo "All done."
