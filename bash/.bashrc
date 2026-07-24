# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# ── Path ──────────────────────────────────────────────────────────────────────
_path_remove_prefix() {
  local prefix="$1" entry new_path=""
  IFS=: read -ra _path_entries <<< "$PATH"
  for entry in "${_path_entries[@]}"; do
    [[ "$entry" == "$prefix"* ]] && continue
    [[ -n "$new_path" ]] && new_path+=":"
    new_path+="$entry"
  done
  PATH="$new_path"
}

_path_prepend() {
  [[ -d "$1" ]] || return
  _path_remove_prefix "$1"
  PATH="$1:$PATH"
}

_remove_runtime_manager_paths() {
  _path_remove_prefix "/opt/anaconda3"
  _path_remove_prefix "$HOME/.nvm"
  unset CONDA_DEFAULT_ENV CONDA_EXE CONDA_PREFIX CONDA_PROMPT_MODIFIER CONDA_PYTHON_EXE CONDA_SHLVL
  unset _CONDA_EXE _CONDA_ROOT _CE_CONDA GSETTINGS_SCHEMA_DIR_CONDA_BACKUP
  unset NVM_DIR NVM_BIN NVM_INC NVM_CD_FLAGS
  hash -r
}
_remove_runtime_manager_paths
unset -f _remove_runtime_manager_paths

_path_prepend "$HOME/.local/bin"

# ── Tools & Runtimes ──────────────────────────────────────────────────────────
[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash

# Mise
command -v mise &>/dev/null && eval "$(mise activate bash)" || {
  _path_prepend "$HOME/.local/share/mise/shims"
}

# Starship Prompt
command -v starship &>/dev/null && eval "$(starship init bash)"

# ── Aliases ───────────────────────────────────────────────────────────────────
[[ -f ~/.config/shell/aliases ]] && source ~/.config/shell/aliases

# Zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init bash --cmd cd)"

unset -f _path_prepend _path_remove_prefix
