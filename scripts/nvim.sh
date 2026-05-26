#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$DOTFILES/scripts/lib/detect_os.sh"

# ── ANSI Palette ──────────────────────────────────────────────────────────────
C_RESET="\033[0m"
C_CYAN="\033[38;5;51m"
C_INDIGO="\033[38;5;99m"
C_GREEN="\033[38;5;82m"
C_AMBER="\033[38;5;214m"
C_GRAY="\033[38;5;244m"
C_BOLD="\033[1m"

# Clean, emoji-free status indicators
I_OK="${C_GREEN}[OK]${C_RESET}"
I_SKIP="${C_GRAY}[SKIP]${C_RESET}"
I_INFO="${C_CYAN}[INFO]${C_RESET}"
I_GEAR="${C_INDIGO}[...]${C_RESET}"
I_WARN="${C_AMBER}[WARN]${C_RESET}"

# ── Fallback Defaults ─────────────────────────────────────────────────────────
[[ -z "$INSTALL_RIPGREP" ]] && INSTALL_RIPGREP=1
[[ -z "$INSTALL_LAZYGIT" ]] && INSTALL_LAZYGIT=1
[[ -z "$INSTALL_UNCRUSTIFY" ]] && INSTALL_UNCRUSTIFY=1
[[ -z "$LINK_NVIM" ]] && LINK_NVIM=1
[[ -z "$LINK_UNCRUSTIFY" ]] && LINK_UNCRUSTIFY=1

# Fallbacks for backup helper if run directly
if ! command -v backup_item &>/dev/null; then
  BACKUP_DIR="$DOTFILES/tmp/backup"
  LOG_FILE="$BACKUP_DIR/backup_log.txt"
  log_backup() {
    local target="$1"
    mkdir -p "$BACKUP_DIR"
    echo "$target" >> "$LOG_FILE"
  }
  backup_item() {
    local target="$1"
    if [[ -e "$target" || -L "$target" ]]; then
      if [[ -L "$target" ]]; then
        local link_dest; link_dest=$(readlink "$target")
        if [[ "$link_dest" == "$DOTFILES"* ]]; then
          rm "$target"
          return
        fi
      fi
      log_backup "$target"
      local rel_path; rel_path="${target#$HOME/}"
      local dest_backup="$BACKUP_DIR/$rel_path"
      mkdir -p "$(dirname "$dest_backup")"
      mv "$target" "$dest_backup"
      echo "  [Fallback Backup] Saved $target to tmp/backup/$rel_path"
    fi
  }
fi

# Visual Loading Spinner
show_spinner() {
  local pid=$1
  local delay=0.1
  local spinstr='|/-\'
  echo -ne "  ${I_GEAR} Installing... "
  while kill -0 "$pid" 2>/dev/null; do
    local temp=${spinstr#?}
    printf "%c" "$spinstr"
    local spinstr=$temp${spinstr%"$temp"}
    sleep $delay
    printf "\b"
  done
  printf "\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b"
  echo -e "  ${I_OK} Done!                "
}

# ── Package Installations ─────────────────────────────────────────────────────
echo -e "${C_CYAN}==> Collecting selected Neovim packages...${C_RESET}"

case "$OS" in
  mac)
    BREW_PKGS=("neovim" "git")
    [[ $INSTALL_RIPGREP -eq 1 ]] && BREW_PKGS+=("ripgrep")
    [[ $INSTALL_LAZYGIT -eq 1 ]] && BREW_PKGS+=("lazygit")
    [[ $INSTALL_UNCRUSTIFY -eq 1 ]] && BREW_PKGS+=("uncrustify")

    echo -e "  ${I_INFO} Installing Homebrew packages: ${C_CYAN}${BREW_PKGS[*]}${C_RESET}"
    brew install "${BREW_PKGS[@]}" &>/dev/null &
    show_spinner $!
    ;;

  arch)
    PACMAN_PKGS=("neovim" "git" "base-devel")
    [[ $INSTALL_RIPGREP -eq 1 ]] && PACMAN_PKGS+=("ripgrep")
    [[ $INSTALL_LAZYGIT -eq 1 ]] && PACMAN_PKGS+=("lazygit")
    [[ $INSTALL_UNCRUSTIFY -eq 1 ]] && PACMAN_PKGS+=("uncrustify")

    echo -e "  ${I_INFO} Syncing Pacman and installing: ${C_CYAN}${PACMAN_PKGS[*]}${C_RESET}"
    sudo pacman -Syu --noconfirm &>/dev/null
    sudo pacman -S --noconfirm --needed "${PACMAN_PKGS[@]}" &>/dev/null &
    show_spinner $!
    ;;

  ubuntu)
    echo -e "  ${I_INFO} Syncing apt repository..."
    sudo apt update &>/dev/null

    APT_PKGS=("git" "build-essential")
    [[ $INSTALL_RIPGREP -eq 1 ]] && APT_PKGS+=("ripgrep")
    [[ $INSTALL_UNCRUSTIFY -eq 1 ]] && APT_PKGS+=("uncrustify")

    echo -e "  ${I_INFO} Installing apt packages: ${C_CYAN}${APT_PKGS[*]}${C_RESET}"
    sudo apt install -y "${APT_PKGS[@]}" &>/dev/null &
    show_spinner $!

    # Modern Neovim manual installation on Ubuntu (apt version is very outdated)
    echo -e "  ${I_INFO} Installing latest stable Neovim binary..."
    NVIM_VER=$(curl -s "https://api.github.com/repos/neovim/neovim/releases/latest" \
      | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
    curl -sLo /tmp/nvim.tar.gz \
      "https://github.com/neovim/neovim/releases/download/v${NVIM_VER}/nvim-linux-x86_64.tar.gz" &>/dev/null
    sudo tar xf /tmp/nvim.tar.gz -C /opt
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

    # Lazygit manual download on Ubuntu
    if [[ $INSTALL_LAZYGIT -eq 1 ]]; then
      echo -e "  ${I_INFO} Installing latest Lazygit binary..."
      LG=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
        | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
      curl -sLo /tmp/lazygit.tar.gz \
        "https://github.com/jesseduffield/lazygit/releases/download/v${LG}/lazygit_${LG}_Linux_x86_64.tar.gz" &>/dev/null
      tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
      sudo install /tmp/lazygit /usr/local/bin
    fi
    ;;
esac

# ── Linking Selected Configurations ───────────────────────────────────────────
echo -e "${C_CYAN}==> Linking Neovim configs...${C_RESET}"

if [[ $LINK_NVIM -eq 1 ]]; then
  NVIM_DIR="$HOME/.config/nvim"
  backup_item "$NVIM_DIR"
  ln -sfn "$DOTFILES/nvim" "$NVIM_DIR"
  echo -e "  ${I_OK} Linked Neovim config directory."
fi

if [[ $INSTALL_UNCRUSTIFY -eq 1 && $LINK_UNCRUSTIFY -eq 1 ]]; then
  backup_item "$HOME/.uncrustify.cfg"
  ln -sf "$DOTFILES/config/uncrustify.cfg" "$HOME/.uncrustify.cfg"
  echo -e "  ${I_OK} Linked Uncrustify formatter config."
fi

# Clean stale Mason Ruby packages
echo -e "${C_CYAN}==> Clearing stale Mason packages (will auto-reinstall on next open)...${C_RESET}"
rm -rf \
  "$HOME/.local/share/nvim/mason/packages/rubocop" \
  "$HOME/.local/share/nvim/mason/packages/ruby-lsp" \
  "$HOME/.local/share/nvim/mason/bin/rubocop" \
  "$HOME/.local/share/nvim/mason/bin/ruby-lsp"
echo -e "  ${I_OK} Cleaned up Mason cache."

echo -e "  ${I_OK} Neovim workspace configuration complete!"
echo ""
