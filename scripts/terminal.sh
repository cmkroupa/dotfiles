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
[[ -z "$INSTALL_TMUX" ]] && INSTALL_TMUX=1
[[ -z "$INSTALL_FZF" ]] && INSTALL_FZF=1
[[ -z "$INSTALL_ZOXIDE" ]] && INSTALL_ZOXIDE=1
[[ -z "$INSTALL_STARSHIP" ]] && INSTALL_STARSHIP=1
[[ -z "$INSTALL_EZA" ]] && INSTALL_EZA=1
[[ -z "$INSTALL_BAT" ]] && INSTALL_BAT=1
[[ -z "$INSTALL_FD" ]] && INSTALL_FD=1
[[ -z "$INSTALL_MISE" ]] && INSTALL_MISE=1
[[ -z "$INSTALL_ZSH_PLUGINS" ]] && INSTALL_ZSH_PLUGINS=1
[[ -z "$INSTALL_FONT" ]] && INSTALL_FONT=1
[[ -z "$INSTALL_GHOSTTY" ]] && INSTALL_GHOSTTY=0

[[ -z "$LINK_TMUX" ]] && LINK_TMUX=1
[[ -z "$LINK_STARSHIP" ]] && LINK_STARSHIP=1
[[ -z "$LINK_MISE" ]] && LINK_MISE=1
[[ -z "$LINK_GHOSTTY" ]] && LINK_GHOSTTY=0
[[ -z "$INJECT_SHELL" ]] && INJECT_SHELL=1

# Fallbacks for backup helpers if run directly without setup.sh
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

if ! command -v backup_file_for_modify &>/dev/null; then
  BACKUP_DIR="$DOTFILES/tmp/backup"
  LOG_FILE="$BACKUP_DIR/backup_log.txt"
  log_backup() {
    local target="$1"
    mkdir -p "$BACKUP_DIR"
    echo "$target" >> "$LOG_FILE"
  }
  backup_file_for_modify() {
    local target="$1"
    if [[ -f "$target" ]]; then
      if [[ -f "$LOG_FILE" ]] && grep -qFx "$target" "$LOG_FILE" 2>/dev/null; then
        return
      fi
      log_backup "$target"
      local rel_path; rel_path="${target#$HOME/}"
      local dest_backup="$BACKUP_DIR/$rel_path"
      mkdir -p "$(dirname "$dest_backup")"
      cp -p "$target" "$dest_backup"
      echo "  [Fallback Backup] Copied $target to tmp/backup/$rel_path"
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
echo -e "${C_CYAN}==> Collecting selected packages for installation...${C_RESET}"

case "$OS" in
  mac)
    # Ensure Homebrew is ready if needed
    if ! command -v brew &>/dev/null; then
      echo -e "  ${I_GEAR} Homebrew not found. Installing..."
      /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" &>/dev/null &
      show_spinner $!
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    # Build brew install array
    BREW_PKGS=()
    [[ $INSTALL_TMUX -eq 1 ]] && BREW_PKGS+=("tmux")
    [[ $INSTALL_FZF -eq 1 ]] && BREW_PKGS+=("fzf")
    [[ $INSTALL_ZOXIDE -eq 1 ]] && BREW_PKGS+=("zoxide")
    [[ $INSTALL_STARSHIP -eq 1 ]] && BREW_PKGS+=("starship")
    [[ $INSTALL_EZA -eq 1 ]] && BREW_PKGS+=("eza")
    [[ $INSTALL_BAT -eq 1 ]] && BREW_PKGS+=("bat")
    [[ $INSTALL_FD -eq 1 ]] && BREW_PKGS+=("fd")
    [[ $INSTALL_MISE -eq 1 ]] && BREW_PKGS+=("mise")
    
    if [[ $INSTALL_ZSH_PLUGINS -eq 1 ]]; then
      BREW_PKGS+=("zsh-syntax-highlighting" "zsh-autosuggestions")
    fi

    if [ ${#BREW_PKGS[@]} -gt 0 ]; then
      echo -e "  ${I_INFO} Installing Homebrew CLI packages: ${C_CYAN}${BREW_PKGS[*]}${C_RESET}"
      brew install "${BREW_PKGS[@]}" &>/dev/null &
      show_spinner $!
    fi

    # Cask items
    if [[ $INSTALL_FONT -eq 1 ]]; then
      echo -e "  ${I_INFO} Installing JetBrainsMono Nerd Font Cask..."
      brew install --cask font-jetbrains-mono-nerd-font &>/dev/null &
      show_spinner $!
    fi

    if [[ $INSTALL_GHOSTTY -eq 1 ]]; then
      echo -e "  ${I_INFO} Installing Ghostty Terminal Cask..."
      brew install --cask ghostty &>/dev/null &
      show_spinner $!
    fi
    ;;

  arch)
    PACMAN_PKGS=()
    [[ $INSTALL_TMUX -eq 1 ]] && PACMAN_PKGS+=("tmux")
    [[ $INSTALL_FZF -eq 1 ]] && PACMAN_PKGS+=("fzf")
    [[ $INSTALL_ZOXIDE -eq 1 ]] && PACMAN_PKGS+=("zoxide")
    [[ $INSTALL_STARSHIP -eq 1 ]] && PACMAN_PKGS+=("starship")
    [[ $INSTALL_EZA -eq 1 ]] && PACMAN_PKGS+=("eza")
    [[ $INSTALL_BAT -eq 1 ]] && PACMAN_PKGS+=("bat")
    [[ $INSTALL_FD -eq 1 ]] && PACMAN_PKGS+=("fd")
    [[ $INSTALL_MISE -eq 1 ]] && PACMAN_PKGS+=("mise")
    
    if [[ $INSTALL_ZSH_PLUGINS -eq 1 ]]; then
      PACMAN_PKGS+=("zsh-syntax-highlighting" "zsh-autosuggestions")
    fi
    
    if [[ $INSTALL_FONT -eq 1 ]]; then
      PACMAN_PKGS+=("ttf-jetbrains-mono-nerd")
    fi

    if [[ $INSTALL_GHOSTTY -eq 1 ]]; then
      PACMAN_PKGS+=("ghostty")
    fi

    if [ ${#PACMAN_PKGS[@]} -gt 0 ]; then
      echo -e "  ${I_INFO} Syncing Pacman and installing: ${C_CYAN}${PACMAN_PKGS[*]}${C_RESET}"
      sudo pacman -Syu --noconfirm &>/dev/null
      sudo pacman -S --noconfirm --needed "${PACMAN_PKGS[@]}" &>/dev/null &
      show_spinner $!
    fi
    ;;

  ubuntu)
    # Basic standard packages
    APT_PKGS=()
    [[ $INSTALL_TMUX -eq 1 ]] && APT_PKGS+=("tmux")
    [[ $INSTALL_FZF -eq 1 ]] && APT_PKGS+=("fzf")
    [[ $INSTALL_ZOXIDE -eq 1 ]] && APT_PKGS+=("zoxide")
    [[ $INSTALL_BAT -eq 1 ]] && APT_PKGS+=("bat")
    [[ $INSTALL_FD -eq 1 ]] && APT_PKGS+=("fd-find")
    
    if [[ $INSTALL_ZSH_PLUGINS -eq 1 ]]; then
      APT_PKGS+=("zsh-syntax-highlighting" "zsh-autosuggestions")
    fi

    if [ ${#APT_PKGS[@]} -gt 0 ]; then
      echo -e "  ${I_INFO} Syncing Apt and installing core packages: ${C_CYAN}${APT_PKGS[*]}${C_RESET}"
      sudo apt update &>/dev/null
      sudo apt install -y "${APT_PKGS[@]}" &>/dev/null &
      show_spinner $!

      # Ubuntu binary standardizer links (bat -> batcat, fd -> fdfind)
      mkdir -p "$HOME/.local/bin"
      if [[ $INSTALL_BAT -eq 1 && -f /usr/bin/batcat ]]; then
        ln -sf /usr/bin/batcat "$HOME/.local/bin/bat"
      fi
      if [[ $INSTALL_FD -eq 1 && -f /usr/bin/fdfind ]]; then
        ln -sf /usr/bin/fdfind "$HOME/.local/bin/fd"
      fi
    fi

    # Eza custom download on Ubuntu if missing
    if [[ $INSTALL_EZA -eq 1 ]]; then
      if ! command -v eza &>/dev/null; then
        echo -e "  ${I_INFO} Fetching latest 'eza' release binary..."
        sudo apt install -y eza 2>/dev/null || {
          EZ=$(curl -s "https://api.github.com/repos/eza-community/eza/releases/latest" \
            | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/')
          curl -sLo /tmp/eza.tar.gz \
            "https://github.com/eza-community/eza/releases/download/v${EZ}/eza_x86_64-unknown-linux-gnu.tar.gz" &>/dev/null
          tar xf /tmp/eza.tar.gz -C /tmp
          sudo install /tmp/eza /usr/local/bin
        }
      fi
    fi

    # Starship custom install on Ubuntu
    if [[ $INSTALL_STARSHIP -eq 1 ]]; then
      if ! command -v starship &>/dev/null; then
        echo -e "  ${I_INFO} Installing Starship Prompt..."
        curl -sS https://starship.rs/install.sh | sh -s -- --yes &>/dev/null &
        show_spinner $!
      fi
    fi

    # Mise custom install on Ubuntu
    if [[ $INSTALL_MISE -eq 1 ]]; then
      if ! command -v mise &>/dev/null; then
        echo -e "  ${I_INFO} Installing Mise Runtime Manager..."
        curl https://mise.run | sh &>/dev/null &
        show_spinner $!
      fi
    fi

    # Font download for Ubuntu
    if [[ $INSTALL_FONT -eq 1 ]]; then
      if [ ! -d ~/.local/share/fonts/JetBrainsMono ]; then
        echo -e "  ${I_INFO} Downloading JetBrainsMono Nerd Font..."
        mkdir -p ~/.local/share/fonts
        curl -sLo /tmp/JetBrainsMono.zip \
          "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip" &>/dev/null
        unzip -qo /tmp/JetBrainsMono.zip "*.ttf" -d ~/.local/share/fonts/JetBrainsMono
        fc-cache -f &>/dev/null
      fi
    fi
    ;;
esac

# ── Linking Selected Configurations ───────────────────────────────────────────
echo -e "${C_CYAN}==> Linking selected terminal configs...${C_RESET}"

if [[ $INSTALL_MISE -eq 1 && $LINK_MISE -eq 1 ]]; then
  mkdir -p "$HOME/.config/mise"
  backup_item "$HOME/.config/mise/config.toml"
  ln -sf "$DOTFILES/config/mise.toml" "$HOME/.config/mise/config.toml"
  echo -e "  ${I_OK} Linked Mise config."
fi

if [[ $INSTALL_TMUX -eq 1 && $LINK_TMUX -eq 1 ]]; then
  backup_item "$HOME/.tmux.conf"
  ln -sf "$DOTFILES/config/tmux.conf" "$HOME/.tmux.conf"
  echo -e "  ${I_OK} Linked tmux config."

  # TPM
  if [[ ! -d ~/.tmux/plugins/tpm ]]; then
    echo -e "  ${I_GEAR} Cloning Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm &>/dev/null &
    show_spinner $!
  fi

  # Auto-install Tmux plugins silently
  if [[ -f ~/.tmux/plugins/tpm/bin/install_plugins ]]; then
    echo -e "  ${I_GEAR} Installing Tmux plugins..."
    bash ~/.tmux/plugins/tpm/bin/install_plugins &>/dev/null &
    show_spinner $!
  fi
fi

if [[ $INSTALL_STARSHIP -eq 1 && $LINK_STARSHIP -eq 1 ]]; then
  backup_item "$HOME/.config/starship.toml"
  ln -sf "$DOTFILES/config/starship.toml" "$HOME/.config/starship.toml"
  echo -e "  ${I_OK} Linked Starship config."
fi

# Ghostty config linking
if [[ $INSTALL_GHOSTTY -eq 1 && $LINK_GHOSTTY -eq 1 ]]; then
  if [[ -d "$HOME/.config/omarchy" ]]; then
    echo -e "  ${I_INFO} Omarchy detected — skipping Ghostty config (managed automatically)."
  else
    mkdir -p "$HOME/.config/ghostty"
    
    backup_item "$HOME/.config/ghostty/config"
    ln -sf "$DOTFILES/config/ghostty/config" "$HOME/.config/ghostty/config"

    backup_item "$HOME/.config/ghostty/platform.conf"
    if [[ "$OS" == "mac" ]]; then
      echo "macos-option-as-alt = true" > "$HOME/.config/ghostty/platform.conf"
    else
      echo -e "gtk-toolbar-style = flat\nasync-backend = epoll" > "$HOME/.config/ghostty/platform.conf"
    fi

    # Link active_theme file (managed dynamically by the theme script)
    active_theme_src="$DOTFILES/config/ghostty/active_theme"
    if [[ ! -f "$active_theme_src" ]]; then
      mkdir -p "$(dirname "$active_theme_src")"
      echo "theme = Catppuccin Macchiato" > "$active_theme_src"
    fi
    backup_item "$HOME/.config/ghostty/active_theme"
    ln -sf "$active_theme_src" "$HOME/.config/ghostty/active_theme"

    echo -e "  ${I_OK} Linked Ghostty config."
  fi
fi

# ── Shell Init Injection ──────────────────────────────────────────────────────
if [[ $INJECT_SHELL -eq 1 ]]; then
  if [[ "$OS" == "mac" ]]; then
    CONF_FILE="$HOME/.zshrc"
    INIT_CMDS=(
      "export DOTFILES=\"$DOTFILES\""
      "source \$DOTFILES/config/zshrc"
    )
  else
    CONF_FILE="$HOME/.bashrc"
    INIT_CMDS=(
      "export DOTFILES=\"$DOTFILES\""
      "source \$DOTFILES/config/aliases"
      "[[ -d \"\$HOME/.local/share/mise/shims\" ]] && export PATH=\"\$HOME/.local/share/mise/shims:\$PATH\""
      "command -v zoxide   &>/dev/null && eval \"\$(zoxide init bash --cmd cd)\""
      "command -v starship &>/dev/null && eval \"\$(starship init bash)\""
      "[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash || true"
    )
  fi

  # Ensure the target rc file is backed up before modification
  backup_file_for_modify "$CONF_FILE"

  if [[ -L "$CONF_FILE" && ! -e "$CONF_FILE" ]]; then
    rm "$CONF_FILE"
  fi
  [[ -f "$CONF_FILE" ]] || touch "$CONF_FILE"

  echo -e "  ${I_INFO} Injecting custom hooks into ${C_AMBER}$CONF_FILE${C_RESET}..."
  for cmd in "${INIT_CMDS[@]}"; do
    grep -qF "$cmd" "$CONF_FILE" || echo "$cmd" >> "$CONF_FILE"
  done
  echo -e "  ${I_OK} Shell profile modified."
fi

# Create hushlogin to avoid login messages
backup_item "$HOME/.hushlogin"
touch "$HOME/.hushlogin"

echo -e "  ${I_OK} Terminal workspace configuration complete!"
echo ""
