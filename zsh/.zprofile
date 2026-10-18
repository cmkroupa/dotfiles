# Login shells: also what Ghostty starts tmux with, so tmux popups inherit this PATH
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
# mise shims let non-interactive commands (popups, scripts) find mise tools; .zshrc activates mise fully
path=("$HOME/.local/bin" "$HOME/.local/share/mise/shims" $path)
