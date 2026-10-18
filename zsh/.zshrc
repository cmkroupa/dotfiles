# ── History ───────────────────────────────────────────────────────────────────
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt HIST_IGNORE_ALL_DUPS SHARE_HISTORY

# ── Path ──────────────────────────────────────────────────────────────────────
typeset -U path PATH
path=("$HOME/.local/bin" $path)

# ── Completions ───────────────────────────────────────────────────────────────
autoload -Uz compinit && compinit
autoload -U up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# ── Tools ─────────────────────────────────────────────────────────────────────
# mise first: it provides fzf, nvim and the language runtimes
command -v mise &>/dev/null && eval "$(mise activate zsh)"
command -v fzf &>/dev/null && source <(fzf --zsh)
command -v starship &>/dev/null && eval "$(starship init zsh)"
command -v zoxide &>/dev/null && eval "$(zoxide init zsh --cmd cd)"

# ── Aliases ───────────────────────────────────────────────────────────────────
[[ -f ~/.config/shell/aliases ]] && source ~/.config/shell/aliases
[[ -f ~/.config/shell/functions ]] && source ~/.config/shell/functions

# ── Plugins (Homebrew or apt) ─────────────────────────────────────────────────
# syntax-highlighting goes last so it sees every widget defined above
for plugin in zsh-autosuggestions zsh-syntax-highlighting; do
  for dir in /opt/homebrew/share /usr/share; do
    [[ -f $dir/$plugin/$plugin.zsh ]] && source $dir/$plugin/$plugin.zsh && break
  done
done
unset plugin dir
