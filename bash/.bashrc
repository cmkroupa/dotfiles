# ── History ───────────────────────────────────────────────────────────────────
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoredups:erasedups
shopt -s histappend
bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# ── Path ──────────────────────────────────────────────────────────────────────
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

# ── Tools ─────────────────────────────────────────────────────────────────────
[[ -f ~/.fzf.bash ]] && source ~/.fzf.bash
[[ -d "$HOME/.local/share/mise/shims" ]] && export PATH="$HOME/.local/share/mise/shims:$PATH"
command -v zoxide  &>/dev/null && eval "$(zoxide init bash --cmd cd)"
command -v starship &>/dev/null && eval "$(starship init bash)"

# ── Aliases ───────────────────────────────────────────────────────────────────
source ~/.config/shell/aliases
