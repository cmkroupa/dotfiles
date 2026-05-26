#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$DOTFILES/scripts"
source "$SCRIPTS/lib/detect_os.sh"

# ── ANSI Palette ──────────────────────────────────────────────────────────────
C_RESET="\033[0m"
C_CYAN="\033[38;5;51m"
C_INDIGO="\033[38;5;99m"
C_GREEN="\033[38;5;82m"
C_AMBER="\033[38;5;214m"
C_GRAY="\033[38;5;244m"
C_BOLD="\033[1m"

# ── Backup Registry ───────────────────────────────────────────────────────────
BACKUP_DIR="$DOTFILES/tmp/backup"
LOG_FILE="$BACKUP_DIR/backup_log.txt"

print_header() {
  clear 2>/dev/null || true
  echo -e "${C_AMBER}┌──────────────────────────────────────────────────────────┐${C_RESET}"
  printf "${C_AMBER}│${C_RESET} ${C_BOLD}%-56s${C_RESET} ${C_AMBER}│\n${C_RESET}" "$1"
  echo -e "${C_AMBER}└──────────────────────────────────────────────────────────┘${C_RESET}"
  echo ""
}

print_header "Dotfiles Uninstaller"

# ── Check if Backup Registry exists ───────────────────────────────────────────
if [[ ! -f "$LOG_FILE" ]]; then
  echo "No active backup registry found inside the cloned repository (tmp/backup/backup_log.txt)."
  echo "Proceeding with standard symlink and injection cleanup..."
  echo ""
  read -p "Proceed with standard cleanup? [y/N]: " reply
  if [[ ! "$reply" =~ ^[Yy]$ ]]; then
    echo "Aborted."
    exit 0
  fi

  echo ""
  echo "==> Removing dotfiles symlinks and configuration blocks..."
  
  # Leverage existing scripts to clean up symlinks and injected lines
  bash "$SCRIPTS/undo_terminal.sh"
  bash "$SCRIPTS/undo_nvim.sh"

  echo "Standard cleanup finished successfully!"
  exit 0
fi

# ── Backup Registry Restoration ───────────────────────────────────────────────
echo "An active backup registry was found."
echo "This will revert modified files and restore original configurations."
echo ""
read -p "Restore your original environment? [y/N]: " reply
if [[ ! "$reply" =~ ^[Yy]$ ]]; then
  echo "Restoration aborted."
  exit 0
fi

echo ""
echo "==> Restoring original configuration from tmp/backup..."

reverse_read_log() {
  if command -v tac &>/dev/null; then
    tac "$LOG_FILE"
  else
    local lines=()
    while IFS= read -r line; do
      lines+=("$line")
    done < "$LOG_FILE"
    for ((i=${#lines[@]}-1; i>=0; i--)); do
      echo "${lines[i]}"
    done
  fi
}

reverse_read_log | while read -r target; do
  [[ -z "$target" ]] && continue

  rel_path="${target#$HOME/}"
  backup_item="$BACKUP_DIR/$rel_path"

  if [[ -L "$target" || -e "$target" ]]; then
    if [[ -L "$target" ]]; then
      link_dest=$(readlink "$target")
      if [[ "$link_dest" == "$DOTFILES"* ]]; then
        rm "$target"
      fi
    elif [[ -f "$target" && ! -e "$backup_item" ]]; then
      rm "$target"
      echo "  Removed: $target"
      continue
    fi
  fi

  if [[ -e "$backup_item" ]]; then
    if [[ -e "$target" && ! -L "$target" ]]; then
      rm -rf "$target"
    fi

    mkdir -p "$(dirname "$target")"
    mv "$backup_item" "$target"
    echo "  Restored: $target"
  else
    if [[ -e "$target" ]]; then
      rm -rf "$target"
      echo "  Removed: $target"
    fi
  fi
done

# Clean up local gitignored tmp directory
rm -rf "$DOTFILES/tmp"

echo ""
echo "Your system has been successfully restored to its original state!"
echo ""
