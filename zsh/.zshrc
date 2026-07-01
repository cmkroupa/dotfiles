# ── History ───────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY

# ── Path ──────────────────────────────────────────────────────────────────────
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"

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
[[ -d "$HOME/.local/share/mise/shims" ]] && export PATH="$HOME/.local/share/mise/shims:$PATH"
command -v starship &>/dev/null && eval "$(starship init zsh)"

# ── Aliases ───────────────────────────────────────────────────────────────────
[[ -f ~/.config/shell/aliases ]] && source ~/.config/shell/aliases


# Added by Antigravity CLI installer
export PATH="/Users/camk/.local/bin:$PATH"

# Zoxide
command -v zoxide  &>/dev/null && eval "$(zoxide init zsh --cmd cd)"

