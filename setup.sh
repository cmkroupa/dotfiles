#!/bin/bash
set -e

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPTS="$DOTFILES/scripts"
source "$SCRIPTS/lib/detect_os.sh"

# ── Unified Backup Engine ─────────────────────────────────────────────────────
BACKUP_DIR="$DOTFILES/tmp/backup"
LOG_FILE="$BACKUP_DIR/backup_log.txt"

log_backup() {
  local target="$1"
  mkdir -p "$BACKUP_DIR"
  echo "$target" >> "$LOG_FILE"
}

export -f log_backup
export BACKUP_DIR
export LOG_FILE

backup_item() {
  local target="$1"
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -L "$target" ]]; then
      local link_dest; link_dest=$(readlink "$target")
      if [[ "$link_dest" == "$DOTFILES"* ]]; then
        echo "  Removing existing dotfiles link: $target"
        rm "$target"
        return
      fi
    fi

    log_backup "$target"
    local rel_path; rel_path="${target#$HOME/}"
    local dest_backup="$BACKUP_DIR/$rel_path"
    mkdir -p "$(dirname "$dest_backup")"
    echo "  Backing up: $target"
    mv "$target" "$dest_backup"
  fi
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
    echo "  Backing up: $target"
    cp -p "$target" "$dest_backup"
  fi
}

export -f backup_item
export -f backup_file_for_modify
export DOTFILES

# ── ANSI Palette ──────────────────────────────────────────────────────────────
C_RESET="\033[0m"
C_CYAN="\033[38;5;51m"
C_INDIGO="\033[38;5;99m"
C_GREEN="\033[38;5;82m"
C_AMBER="\033[38;5;214m"
C_GRAY="\033[38;5;244m"
C_BOLD="\033[1m"

# ── Simple UI Helpers ─────────────────────────────────────────────────────────
print_header() {
  clear 2>/dev/null || true
  echo -e "${C_INDIGO}┌──────────────────────────────────────────────────────────┐${C_RESET}"
  printf "${C_INDIGO}│${C_RESET} ${C_BOLD}%-56s${C_RESET} ${C_INDIGO}│\n${C_RESET}" "$1"
  echo -e "${C_INDIGO}└──────────────────────────────────────────────────────────┘${C_RESET}"
  echo ""
}

ask_step() {
  local title="$1"
  local desc="$2"
  local default="$3"
  local ans

  echo -e "  ${C_CYAN}${C_BOLD}${title}${C_RESET}"
  echo -e "  ${C_GRAY}${desc}${C_RESET}"
  if [[ "$default" == "Y" ]]; then
    read -p "  Enable? [Y/n]: " ans
    if [[ -z "$ans" || "$ans" =~ ^[Yy]$ ]]; then
      echo ""
      return 0
    else
      echo ""
      return 1
    fi
  else
    read -p "  Enable? [y/N]: " ans
    if [[ "$ans" =~ ^[Yy]$ ]]; then
      echo ""
      return 0
    else
      echo ""
      return 1
    fi
  fi
}

# ── Initialization & Non-Interactive Detection ────────────────────────────────
usage() {
  cat <<EOF
Usage: $(basename "$0") [flags]

Flags:
  --all               Non-interactive Terminal and Neovim setup
  --terminal          Non-interactive Terminal setup
  --nvim              Non-interactive Neovim setup
  --non-interactive   Skip visual UI questions (use with other flags)

Without flags, setup runs an interactive wizard.
EOF
}

INTERACTIVE=1
RUN_TERMINAL=0
RUN_NVIM=0

for arg in "$@"; do
  case "$arg" in
    --all)              INTERACTIVE=0; RUN_TERMINAL=1; RUN_NVIM=1 ;;
    --terminal)         INTERACTIVE=0; RUN_TERMINAL=1 ;;
    --nvim)             INTERACTIVE=0; RUN_NVIM=1 ;;
    --non-interactive)  INTERACTIVE=0 ;;
    --help|-h)          usage; exit 0 ;;
    *)                  echo "Unknown flag: $arg"; usage; exit 1 ;;
  esac
done

if [[ ! -t 0 ]]; then
  INTERACTIVE=0
fi

# ── Interactive Setup ─────────────────────────────────────────────────────────
if [[ $INTERACTIVE -eq 1 ]]; then
  print_header "Dotfiles Installer"
  echo "This script configures your Terminal and Neovim environments."
  echo "Modified files will be backed up in the gitignored 'tmp/' directory."
  echo "You can undo all changes by running './undo.sh'."
  echo ""

  # ── Terminal Setup Section ──
  if ask_step "Set up Terminal?" "Installs standard terminal packages (tmux, fzf, zoxide, starship, eza, bat, fd, mise, shell plugins, nerd font) and sets up configs" "Y"; then
    RUN_TERMINAL=1
    INSTALL_TMUX=1
    INSTALL_FZF=1
    INSTALL_ZOXIDE=1
    INSTALL_STARSHIP=1
    INSTALL_EZA=1
    INSTALL_BAT=1
    INSTALL_FD=1
    INSTALL_MISE=1
    INSTALL_ZSH_PLUGINS=1
    INSTALL_FONT=1
    LINK_TMUX=1
    LINK_STARSHIP=1
    LINK_MISE=1

    ask_step "Install Ghostty terminal?" "Optional GPU-accelerated terminal emulator" "N" && INSTALL_GHOSTTY=1 && LINK_GHOSTTY=1 || { INSTALL_GHOSTTY=0; LINK_GHOSTTY=0; }
    ask_step "Inject shell profile hooks?" "Adds custom aliases and tools to ~/.zshrc or ~/.bashrc" "Y" && INJECT_SHELL=1 || INJECT_SHELL=0
  else
    RUN_TERMINAL=0
  fi

  # ── Neovim Setup Section ──
  if ask_step "Set up Neovim?" "Installs Neovim, search utilities, formatters, and links config directories" "Y"; then
    RUN_NVIM=1
    INSTALL_RIPGREP=1
    INSTALL_LAZYGIT=1
    INSTALL_UNCRUSTIFY=1
    LINK_NVIM=1
    LINK_UNCRUSTIFY=1

    if ask_step "Configure Neovim Language Servers (LSPs)?" "Auto-configures Python, Rust, C/C++, Lua, and Web by default" "Y"; then
      ENABLED_LANGS=("python" "rust" "c" "lua" "web")
      ask_step "Enable Ruby / Rails support?" "Installs ruby_lsp, rubocop, and vim-rails" "N" && ENABLED_LANGS+=("ruby")
      ask_step "Enable Go support?" "Installs gopls and gofmt" "Y" && ENABLED_LANGS+=("go")

      INSTALL_RUNTIMES=1
    else
      ENABLED_LANGS=()
      INSTALL_RUNTIMES=0
    fi
  else
    RUN_NVIM=0
  fi
else
  # Non-interactive defaults
  INSTALL_TMUX=1
  INSTALL_FZF=1
  INSTALL_ZOXIDE=1
  INSTALL_STARSHIP=1
  INSTALL_EZA=1
  INSTALL_BAT=1
  INSTALL_FD=1
  INSTALL_MISE=1
  INSTALL_ZSH_PLUGINS=1
  INSTALL_FONT=1
  INSTALL_GHOSTTY=0

  LINK_TMUX=1
  LINK_STARSHIP=1
  LINK_MISE=1
  LINK_GHOSTTY=0
  INJECT_SHELL=1

  INSTALL_RIPGREP=1
  INSTALL_LAZYGIT=1
  INSTALL_UNCRUSTIFY=1
  LINK_NVIM=1
  LINK_UNCRUSTIFY=1
  INSTALL_RUNTIMES=1

  ENABLED_LANGS=("python" "rust" "go" "lua" "c" "web")
fi

# Export parameters
export INSTALL_TMUX INSTALL_FZF INSTALL_ZOXIDE INSTALL_STARSHIP INSTALL_EZA INSTALL_BAT INSTALL_FD INSTALL_MISE INSTALL_ZSH_PLUGINS INSTALL_FONT INSTALL_GHOSTTY
export LINK_TMUX LINK_STARSHIP LINK_MISE LINK_GHOSTTY INJECT_SHELL
export INSTALL_RIPGREP INSTALL_LAZYGIT INSTALL_UNCRUSTIFY LINK_NVIM LINK_UNCRUSTIFY INSTALL_RUNTIMES

# ── Write Dynamic Configuration Files ──────────────────────────────────────────
if [[ $RUN_NVIM -eq 1 ]]; then
  print_header "Configuring Neovim LSPs"
  LSP_FILE="$DOTFILES/nvim/lua/config/lsp_servers.lua"
  backup_file_for_modify "$LSP_FILE"

  cat > "$LSP_FILE" <<EOF
-- Generated dynamically by dotfiles setup.sh
local enabled = {
EOF
  for lang in "${ENABLED_LANGS[@]}"; do
    echo "  \"$lang\"," >> "$LSP_FILE"
  done
  cat >> "$LSP_FILE" <<'EOF'
}

-- ── Mapping ───────────────────────────────────────────────────────────────────
local map = {
  ruby   = { extra_lsp    = { "ruby_lsp" },
             mason_tools  = { "rubocop" } },
  python = { mason_lsp    = { "pyright" },
             mason_tools  = { "black", "ruff" } },
  go     = { mason_lsp    = { "gopls" } },
  rust   = { mason_lsp    = { "rust_analyzer" } },
  lua    = { mason_lsp    = { "lua_ls" },
             mason_tools  = { "stylua" } },
  c      = { mason_lsp    = { "clangd" },
             mason_tools  = { "clang-format" } },
  web    = { mason_lsp    = { "html", "cssls", "emmet_ls" } },
}

local result = { mason_lsp = {}, mason_tools = {}, extra_lsp = {} }

for _, lang in ipairs(enabled) do
  local entry = map[lang] or {}
  for _, s in ipairs(entry.mason_lsp   or {}) do table.insert(result.mason_lsp,   s) end
  for _, s in ipairs(entry.mason_tools or {}) do table.insert(result.mason_tools, s) end
  for _, s in ipairs(entry.extra_lsp   or {}) do table.insert(result.extra_lsp,   s) end
end

return result
EOF
  echo "  Updated Neovim enabled LSPs in config/lsp_servers.lua"
fi

if [[ $RUN_TERMINAL -eq 1 && $LINK_MISE -eq 1 ]]; then
  MISE_FILE="$DOTFILES/config/mise.toml"
  backup_file_for_modify "$MISE_FILE"

  cat > "$MISE_FILE" <<EOF
# Generated dynamically by dotfiles setup.sh
[tools]
EOF
  for lang in "${ENABLED_LANGS[@]}"; do
    if [[ "$lang" == "c" ]]; then
      continue
    fi
    if [[ "$lang" == "web" ]]; then
      echo "node    = \"lts\"" >> "$MISE_FILE"
    else
      echo "$lang    = \"latest\"" >> "$MISE_FILE"
    fi
  done
  echo "  Updated Mise runtimes in config/mise.toml"
fi

# ── Execute Scripts ───────────────────────────────────────────────────────────
if [[ $RUN_TERMINAL -eq 1 ]]; then
  print_header "Installing Terminal Utilities"
  bash "$SCRIPTS/terminal.sh"
fi

if [[ $RUN_NVIM -eq 1 ]]; then
  print_header "Installing Neovim & Formatting Tools"
  bash "$SCRIPTS/nvim.sh"
  if [[ $INSTALL_RUNTIMES -eq 1 ]]; then
    bash "$SCRIPTS/runtimes.sh"
  fi
fi

# ── Dynamic C/C++ LSP Instructions ────────────────────────────────────────────
print_header "Setup Complete"
echo "Your development workspace has been successfully configured."
echo "Please reload your shell profile to see changes: 'source ~/.zshrc' (macOS) or 'source ~/.bashrc' (Linux)."
echo "To revert all changes, run: ./undo.sh"
echo ""
echo "=== Keybindings & shortcuts ==="
echo "  * Neovim Leader Key  : Space"
echo "  * Tmux Prefix Key    : Ctrl + Space"
echo "  * Tmux Keybinding    : Press prefix, release keys, then '?' inside tmux"
echo "  * View Shell Aliases : Type 'aliases' in the terminal to list custom shortcuts"
echo ""
echo "=== C/C++ Clangd LSP Configuration ==="
echo "Clangd C/C++ LSP requires a 'compile_commands.json' file at the root of your project directory."
echo "To generate it from a Makefile, run:"
echo "  lspinit [path]   (defaults to current directory)"
echo ""
echo "This alias runs 'compiledb make' under the hood. You will need compiledb installed:"
echo "  pip install compiledb"
echo ""
