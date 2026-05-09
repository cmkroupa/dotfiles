#!/bin/bash

DOTFILES="$HOME/dotfiles"

echo "Setting up symlinks..."

# Ensure config directory exists
mkdir -p "$HOME/.config"

# Clean up existing links or directories
rm -rf "$HOME/.bash_aliases"
rm -rf "$HOME/.tmux.conf"
rm -rf "$HOME/.config/nvim"

# Create symlinks using absolute paths
ln -sf "$DOTFILES/.bash_aliases" "$HOME/.bash_aliases"
ln -sf "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
ln -sf "$DOTFILES/nvim" "$HOME/.config/nvim"

# Helper to inject source command
inject_source() {
    local rc_file="$1"
    if [ -f "$rc_file" ]; then
        grep -q "source $DOTFILES/.bash_aliases" "$rc_file" || \
        echo "source $DOTFILES/.bash_aliases" >> "$rc_file"
    fi
}

# Update both shell configs if they exist
inject_source "$HOME/.bashrc"
inject_source "$HOME/.zshrc"

echo "Done."

# Detect active shell to give the right instruction
if [[ "$SHELL" == *"zsh"* ]]; then
    echo "Run: source ~/.zshrc"
else
    echo "Run: source ~/.bashrc"
fi
