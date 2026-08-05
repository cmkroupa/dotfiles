# ── History ───────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY

# ── Path ──────────────────────────────────────────────────────────────────────
typeset -U path PATH

_path_prepend() {
  [[ -d "$1" ]] || return
  path=("$1" "${path[@]}")
}

_remove_runtime_manager_paths() {
  local -a cleaned
  local entry
  for entry in "${path[@]}"; do
    case "$entry" in
      /opt/anaconda3*|"$HOME"/.nvm*) ;;
      *) cleaned+=("$entry") ;;
    esac
  done
  path=("${cleaned[@]}")
  export PATH
  unset CONDA_DEFAULT_ENV CONDA_EXE CONDA_PREFIX CONDA_PROMPT_MODIFIER CONDA_PYTHON_EXE CONDA_SHLVL
  unset _CONDA_EXE _CONDA_ROOT _CE_CONDA GSETTINGS_SCHEMA_DIR_CONDA_BACKUP
  unset NVM_DIR NVM_BIN NVM_INC NVM_CD_FLAGS
  rehash
}
_remove_runtime_manager_paths
unfunction _remove_runtime_manager_paths

_path_prepend "$HOME/.local/bin"

# ── Completions ───────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# ── Plugins ───────────────────────────────────────────────────────────────────
_source_plugin() {
  local name="$1" file="$1.zsh"
  local -a candidates=(
    "/usr/share/$name/$file"
    "/usr/share/zsh/plugins/$name/$file"
    "/usr/share/zsh-$name/$file"
    "/opt/homebrew/share/$name/$file"
  )
  for p in "${candidates[@]}"; do [[ -f "$p" ]] && source "$p" && return; done
}
_source_plugin zsh-syntax-highlighting
_source_plugin zsh-autosuggestions

# ── Tools ─────────────────────────────────────────────────────────────────────
[[ -f ~/.fzf.zsh ]] && source ~/.fzf.zsh
if command -v mise &>/dev/null; then
  eval "$(mise activate zsh)"
else
  _path_prepend "$HOME/.local/share/mise/shims"
fi
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ── Aliases ───────────────────────────────────────────────────────────────────
[[ -f ~/.config/shell/aliases ]] && source ~/.config/shell/aliases

# Zoxide
command -v zoxide  &>/dev/null && eval "$(zoxide init zsh --cmd cd)"

unfunction _path_prepend

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/camk/.lmstudio/bin"
# End of LM Studio CLI section

