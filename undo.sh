#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$DOTFILES/scripts"

usage() {
  cat <<EOF
Usage: $(basename "$0") [flags]

Removes symlinks and injected shell lines created by setup.sh.
Does NOT uninstall packages or language runtimes.

Flags (combinable):
  --all        Run --terminal and --nvim
  --terminal   Undo terminal setup
  --nvim       Undo nvim setup
EOF
}

if [[ $# -eq 0 ]]; then
  usage
  exit 1
fi

RUN_TERMINAL=0
RUN_NVIM=0

for arg in "$@"; do
  case "$arg" in
    --all)      RUN_TERMINAL=1; RUN_NVIM=1 ;;
    --terminal) RUN_TERMINAL=1 ;;
    --nvim)     RUN_NVIM=1 ;;
    --help|-h)  usage; exit 0 ;;
    *)          echo "Unknown flag: $arg"; usage; exit 1 ;;
  esac
done

[[ $RUN_TERMINAL -eq 1 ]] && bash "$SCRIPTS/undo_terminal.sh"
[[ $RUN_NVIM     -eq 1 ]] && bash "$SCRIPTS/undo_nvim.sh"

echo "All done."
