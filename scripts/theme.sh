#!/bin/bash

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# ── ANSI Palette (Standard 16 Colors for Dynamic Terminal Theme Morphing) ─────
C_RESET="\033[0m"
C_CYAN="\033[36m"
C_INDIGO="\033[35m"
C_GREEN="\033[32m"
C_AMBER="\033[33m"
C_GRAY="\033[90m"
C_BOLD="\033[1m"

# ── Config Constants ──────────────────────────────────────────────────────────
THEMES=("catppuccin" "tokyonight" "gruvbox" "nord")
THEME_LABELS=(
  "Catppuccin Macchiato  (Sleek pastel dark)"
  "Tokyo Night           (Vibrant deep blue-gray)"
  "Gruvbox               (Warm retro dark)"
  "Nord                  (Cool arctic bluish-gray)"
)

# Read active/original theme to enable instant restore if aborted
ORIGINAL_THEME="catppuccin"
if [[ -f "$DOTFILES/nvim/lua/config/theme.lua" ]]; then
  ORIGINAL_THEME=$(grep -o '"[^"]*"' "$DOTFILES/nvim/lua/config/theme.lua" | tr -d '"' | head -n1 || echo "catppuccin")
fi

# ── Helper Functions ──────────────────────────────────────────────────────────
apply_preview_theme() {
  local theme="$1"
  local ghostty_active_theme="$DOTFILES/config/ghostty/active_theme"
  mkdir -p "$(dirname "$ghostty_active_theme")"
  
  case "$theme" in
    catppuccin)
      echo "theme = Catppuccin Macchiato" > "$ghostty_active_theme"
      ;;
    tokyonight)
      echo "theme = TokyoNight" > "$ghostty_active_theme"
      ;;
    gruvbox)
      echo "theme = Gruvbox Dark Hard" > "$ghostty_active_theme"
      ;;
    nord)
      echo "theme = Nord" > "$ghostty_active_theme"
      ;;
  esac

  # Touch the main Ghostty config to force live reload
  if [[ -e "$HOME/.config/ghostty/config" ]]; then
    touch -h "$HOME/.config/ghostty/config" 2>/dev/null || true
    touch "$HOME/.config/ghostty/config" 2>/dev/null || true
  fi
  # Also touch active_theme
  if [[ -e "$HOME/.config/ghostty/active_theme" ]]; then
    touch -h "$HOME/.config/ghostty/active_theme" 2>/dev/null || true
    touch "$HOME/.config/ghostty/active_theme" 2>/dev/null || true
  fi
}

apply_terminal_colors() {
  local theme="$1"
  local bg="" fg=""
  local c0="" c1="" c2="" c3="" c4="" c5="" c6="" c7=""
  local c8="" c9="" c10="" c11="" c12="" c13="" c14="" c15=""
  
  case "$theme" in
    catppuccin)
      bg="#24273a"; fg="#cad3f5"
      c0="#1e2030"; c1="#ed8796"; c2="#a6da95"; c3="#eed49f"
      c4="#8aadf4"; c5="#f5bde6"; c6="#8bd5ca"; c7="#a5adcb"
      c8="#5b6078"; c9="#ed8796"; c10="#a6da95"; c11="#eed49f"
      c12="#8aadf4"; c13="#f5bde6"; c14="#8bd5ca"; c15="#cad3f5"
      ;;
    tokyonight)
      bg="#1a1b26"; fg="#c0caf5"
      c0="#15161e"; c1="#f7768e"; c2="#9ece6a"; c3="#e0af68"
      c4="#7aa2f7"; c5="#bb9af7"; c6="#7dcfff"; c7="#a9b1d6"
      c8="#414868"; c9="#f7768e"; c10="#9ece6a"; c11="#e0af68"
      c12="#7aa2f7"; c13="#bb9af7"; c14="#7dcfff"; c15="#c0caf5"
      ;;
    gruvbox)
      bg="#1d2021"; fg="#ebdbb2"
      c0="#282828"; c1="#cc241d"; c2="#98971a"; c3="#d79921"
      c4="#458588"; c5="#b16286"; c6="#689d6a"; c7="#a89984"
      c8="#928374"; c9="#fb4934"; c10="#b8bb26"; c11="#fabd2f"
      c12="#83a598"; c13="#d3869b"; c14="#8ec07c"; c15="#ebdbb2"
      ;;
    nord)
      bg="#2e3440"; fg="#d8dee9"
      c0="#3b4252"; c1="#bf616a"; c2="#a3be8c"; c3="#ebcb8b"
      c4="#81a1c1"; c5="#b48ead"; c6="#88c0d0"; c7="#e5e9f0"
      c8="#4c566a"; c9="#bf616a"; c10="#a3be8c"; c11="#ebcb8b"
      c12="#81a1c1"; c13="#b48ead"; c14="#8fbcbb"; c15="#eceff4"
      ;;
  esac

  if [[ -n "$bg" ]]; then
    # Output OSC escape sequences directly to /dev/tty to instantly update the active terminal window
    printf "\033]10;%s\007" "$fg" > /dev/tty
    printf "\033]11;%s\007" "$bg" > /dev/tty
    printf "\033]4;0;%s\007" "$c0" > /dev/tty
    printf "\033]4;1;%s\007" "$c1" > /dev/tty
    printf "\033]4;2;%s\007" "$c2" > /dev/tty
    printf "\033]4;3;%s\007" "$c3" > /dev/tty
    printf "\033]4;4;%s\007" "$c4" > /dev/tty
    printf "\033]4;5;%s\007" "$c5" > /dev/tty
    printf "\033]4;6;%s\007" "$c6" > /dev/tty
    printf "\033]4;7;%s\007" "$c7" > /dev/tty
    printf "\033]4;8;%s\007" "$c8" > /dev/tty
    printf "\033]4;9;%s\007" "$c9" > /dev/tty
    printf "\033]4;10;%s\007" "$c10" > /dev/tty
    printf "\033]4;11;%s\007" "$c11" > /dev/tty
    printf "\033]4;12;%s\007" "$c12" > /dev/tty
    printf "\033]4;13;%s\007" "$c13" > /dev/tty
    printf "\033]4;14;%s\007" "$c14" > /dev/tty
    printf "\033]4;15;%s\007" "$c15" > /dev/tty
  fi
}

commit_theme() {
  local theme="$1"
  
  # 1. Permanent Ghostty theme
  apply_preview_theme "$theme"
  apply_terminal_colors "$theme"
  
  # 2. Permanent Neovim theme
  local nvim_theme_file="$DOTFILES/nvim/lua/config/theme.lua"
  mkdir -p "$(dirname "$nvim_theme_file")"
  echo "return \"$theme\"" > "$nvim_theme_file"
  
  clear 2>/dev/null || true
  echo -e "${C_GREEN}[OK] Theme successfully updated across Neovim and Ghostty to: ${theme}${C_RESET}\n"
}

cancel_theme() {
  apply_preview_theme "$ORIGINAL_THEME"
  printf '\033[0m'
  echo -e "\n${C_AMBER}[WARN] Selection cancelled.${C_RESET}"
  exit 0
}

# Mathematically pads lines to ensure pixel-perfect straight borders inside FZF
print_preview_line() {
  local content="$1"
  # Strip all ANSI escape sequences using portable bash regex substitution
  local visible; visible=$(echo -e "$content" | sed $'s/\e\\[[0-9;]*[a-zA-Z]//g' | wc -c)
  visible=$((visible - 1)) # Strip wc trailing newline byte
  
  local target_width=44
  local pad_len=$((target_width - visible))
  local padding=""
  if [ $pad_len -gt 0 ]; then
    padding=$(printf '%*s' "$pad_len")
  fi
  
  echo -e "  ${C_GRAY}│${C_RESET} ${content}${padding} ${C_GRAY}│${C_RESET}"
}

draw_menu() {
  clear 2>/dev/null || true
  echo -e "${C_INDIGO}┌──────────────────────────────────────────────────────────┐${C_RESET}"
  printf "${C_INDIGO}│${C_RESET} ${C_BOLD}%-56s${C_RESET} ${C_INDIGO}│\n${C_RESET}" "THEME SELECTOR & LIVE PREVIEW"
  echo -e "${C_INDIGO}└──────────────────────────────────────────────────────────┘${C_RESET}"
  echo -e "  Use ${C_CYAN}Up/Down Arrows${C_RESET} (or ${C_CYAN}j/k${C_RESET}, or ${C_CYAN}1-4${C_RESET}) to preview themes."
  echo -e "  Press ${C_GREEN}Enter${C_RESET} to select, or ${C_Esc/q}${C_RESET} Esc/q to cancel.\n"

  for i in 0 1 2 3; do
    local label="${THEME_LABELS[$i]}"
    if [[ $i -eq $SELECTED_INDEX ]]; then
      echo -e "    ${C_GREEN}>${C_RESET} ${C_BOLD}${C_CYAN}[ $label ]${C_RESET}"
    else
      echo -e "        ${C_GRAY}  $label  ${C_RESET}"
    fi
  done
  echo ""
}

draw_preview() {
  local theme="$1"
  
  # Mock Neovim window (using ANSI colors dynamically styled by terminal colorscheme)
  echo -e "  ${C_GRAY}┌── Neovim: workspace.cpp ───────────────────────────┐${C_RESET}"
  print_preview_line "${C_GRAY} 1${C_RESET} ${C_AMBER}#include${C_RESET} ${C_GREEN}<iostream>${C_RESET}"
  print_preview_line "${C_GRAY} 2${C_RESET} ${C_AMBER}#include${C_RESET} ${C_GREEN}<vector>${C_RESET}"
  print_preview_line "${C_GRAY} 3${C_RESET} ${C_AMBER}#include${C_RESET} ${C_GREEN}<string>${C_RESET}"
  print_preview_line "${C_GRAY} 4${C_RESET}"
  print_preview_line "${C_GRAY} 5${C_RESET} ${C_AMBER}namespace${C_RESET} ${C_CYAN}dev${C_RESET} {"
  print_preview_line "${C_GRAY} 6${C_RESET}"
  print_preview_line "${C_GRAY} 7${C_RESET} ${C_AMBER}class${C_RESET} ${C_CYAN}Workspace${C_RESET} {"
  print_preview_line "${C_GRAY} 8${C_RESET} ${C_AMBER}private${C_RESET}:"
  print_preview_line "${C_GRAY} 9${C_RESET}     ${C_CYAN}std::string${C_RESET} name;"
  print_preview_line "${C_GRAY}10${C_RESET}     ${C_CYAN}std::vector<std::string>${C_RESET} tools;"
  print_preview_line "${C_GRAY}11${C_RESET}"
  print_preview_line "${C_GRAY}12${C_RESET} ${C_AMBER}public${C_RESET}:"
  print_preview_line "${C_GRAY}13${C_RESET}     ${C_CYAN}Workspace${C_RESET}(${C_CYAN}std::string${C_RESET} n) : name(n) {"
  print_preview_line "${C_GRAY}14${C_RESET}         tools = {${C_GREEN}\"nvim\"${C_RESET}, ${C_GREEN}\"tmux\"${C_RESET}, ${C_GREEN}\"zsh\"${C_RESET}};"
  print_preview_line "${C_GRAY}15${C_RESET}     }"
  print_preview_line "${C_GRAY}16${C_RESET}"
  print_preview_line "${C_GRAY}17${C_RESET}     ${C_AMBER}void${C_RESET} ${C_CYAN}show${C_RESET}() ${C_AMBER}const${C_RESET} {"
  print_preview_line "${C_GRAY}18${C_RESET}         ${C_CYAN}std::cout${C_RESET} << name << ${C_GREEN}\"\\\\n\"${C_RESET};"
  print_preview_line "${C_GRAY}19${C_RESET}         ${C_AMBER}for${C_RESET} (${C_AMBER}const auto${C_RESET}& t : tools) {"
  print_preview_line "${C_GRAY}20${C_RESET}             ${C_CYAN}std::cout${C_RESET} << ${C_GREEN}\"- \"${C_RESET} << t << ${C_GREEN}\"\\\\n\"${C_RESET};"
  print_preview_line "${C_GRAY}21${C_RESET}         }"
  print_preview_line "${C_GRAY}22${C_RESET}     }"
  print_preview_line "${C_GRAY}23${C_RESET} };"
  print_preview_line "${C_GRAY}24${C_RESET}"
  print_preview_line "${C_GRAY}25${C_RESET} } ${C_GRAY}// namespace dev${C_RESET}"
  print_preview_line "${C_GRAY}26${C_RESET}"
  print_preview_line "${C_GRAY}27${C_RESET} ${C_AMBER}int${C_RESET} ${C_CYAN}main${C_RESET}() {"
  print_preview_line "${C_GRAY}28${C_RESET}     ${C_CYAN}dev::Workspace${C_RESET} ws(${C_GREEN}\"Camk\"${C_RESET});"
  print_preview_line "${C_GRAY}29${C_RESET}     ws.${C_CYAN}show${C_RESET}();"
  print_preview_line "${C_GRAY}30${C_RESET}     ${C_AMBER}return${C_RESET} ${C_GREEN}0${C_RESET};"
  print_preview_line "${C_GRAY}31${C_RESET} }"
  echo -e "  ${C_GRAY}├────────────────────────────────────────────────────┤${C_RESET}"
  
  # Statusline (simulates lualine visual style using inverted video and standard ANSI codes)
  print_preview_line "\033[7m NORMAL \033[0m \033[7m workspace.cpp \033[0m \033[90mcpp -----------\033[0m \033[7m 17:5 \033[0m"
  echo -e "  ${C_GRAY}└────────────────────────────────────────────────────┘${C_RESET}"
  echo ""
  
  # Mock Terminal window (simulates custom shell prompt and directories)
  echo -e "  ${C_GRAY}┌── Terminal Preview ────────────────────────────────┐${C_RESET}"
  print_preview_line "${C_INDIGO}dotfiles${C_RESET}  ${C_AMBER}DCS${C_RESET} ${C_GREEN}>\033[0m ls -F"
  print_preview_line "${C_CYAN}bin/${C_RESET}      ${C_CYAN}config/${C_RESET}   ${C_CYAN}nvim/${C_RESET}     ${C_GREEN}setup.sh*${C_RESET}  ${C_GREEN}undo.sh*${C_RESET}"
  echo -e "  ${C_GRAY}└────────────────────────────────────────────────────┘${C_RESET}"
  echo ""
}

# ── Fallback Menu ─────────────────────────────────────────────────────────────
show_fallback_menu() {
  echo "=== Theme Selector ==="
  echo "Select a visual theme:"
  echo "  1) Catppuccin Macchiato"
  echo "  2) Tokyo Night"
  echo "  3) Gruvbox"
  echo "  4) Nord"
  echo ""
  read -p "Enter choice [1-4]: " choice
  case "$choice" in
    1) commit_theme "catppuccin" ;;
    2) commit_theme "tokyonight" ;;
    3) commit_theme "gruvbox" ;;
    4) commit_theme "nord" ;;
    *) echo "Invalid choice."; exit 1 ;;
  esac
}

# ── Interactive FZF-Driven Menu ────────────────────────────────────────────────
show_menu() {
  if ! command -v fzf &>/dev/null; then
    show_fallback_menu
    return
  fi

  local pw="right:65%"
  fzf --version 2>/dev/null | grep -qE '^0\.([3-9][0-9]|2[7-9])\.' && pw="right:65%:border-rounded"

  local tmpfile
  tmpfile=$(mktemp)
  trap 'rm -f "$tmpfile"; cancel_theme' INT

  # Pipe items into fzf and redirect selection to a temp file.
  # Avoids $() command substitution which closes TTY file descriptors on Linux bash 5.x.
  printf "catppuccin\ntokyonight\ngruvbox\nnord" | fzf \
    --ansi \
    --prompt="Select Theme > " \
    --header=$'Use Arrow keys to navigate. Press Enter to select, Esc to cancel.\n\n' \
    --border=rounded \
    --layout=reverse \
    --preview="bash '$DOTFILES/scripts/theme.sh' --preview {}" \
    --preview-window="$pw" \
    > "$tmpfile"

  local fzf_exit=$?
  trap - INT

  local selected
  selected=$(< "$tmpfile")
  rm -f "$tmpfile"

  if [[ $fzf_exit -ne 0 ]] || [[ -z "$selected" ]]; then
    cancel_theme
  else
    commit_theme "$selected"
  fi
}

# ── Entrypoint ────────────────────────────────────────────────────────────────
if [[ "$1" == "--preview" ]]; then
  theme="$2"
  apply_preview_theme "$theme"
  apply_terminal_colors "$theme"
  draw_preview "$theme"
  exit 0
fi

if [[ $# -eq 0 ]]; then
  show_menu
else
  case "$1" in
    catppuccin|tokyonight|gruvbox|nord) commit_theme "$1" ;;
    *) echo "Usage: theme [catppuccin | tokyonight | gruvbox | nord]"; exit 1 ;;
  esac
fi
