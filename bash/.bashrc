# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# ── Path ──────────────────────────────────────────────────────────────────────
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/dotfiles/bin:$PATH"

# ── Tools & Runtimes ──────────────────────────────────────────────────────────
[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash

# Conda (only if installed)
if [[ -f /opt/anaconda3/bin/conda ]]; then
  __conda_setup="$('/opt/anaconda3/bin/conda' 'shell.bash' 'hook' 2>/dev/null)"
  [[ $? -eq 0 ]] && eval "$__conda_setup" || export PATH="/opt/anaconda3/bin:$PATH"
  unset __conda_setup
fi

# Mise
command -v mise &>/dev/null && eval "$(mise activate bash)" || {
  [[ -d "$HOME/.local/share/mise/shims" ]] && export PATH="$HOME/.local/share/mise/shims:$PATH"
}

# Starship Prompt
command -v starship &>/dev/null && eval "$(starship init bash)"

# ── Aliases ───────────────────────────────────────────────────────────────────
[[ -f ~/.config/shell/aliases ]] && source ~/.config/shell/aliases


# Added by Antigravity CLI installer
export PATH="/Users/camk/.local/bin:$PATH"

# Zoxide
command -v zoxide &>/dev/null && eval "$(zoxide init bash --cmd cd)"

