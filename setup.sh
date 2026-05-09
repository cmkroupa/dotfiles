#!/bin/bash

DOTFILES="$HOME/dotfiles"

echo "Setting up symlinks..."

ln -sf "$DOTFILES/.bash_aliases" "$HOME/.bash_aliases"
ln -sf "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"
ln -sf "$DOTFILES/nvim" "$HOME/.config/nvim"

# bash
if [ -f "$HOME/.bashrc" ]; then
  grep -q "source ~/dotfiles/.bash_aliases" "$HOME/.bashrc" || \
    echo "source ~/dotfiles/.bash_aliases" >> "$HOME/.bashrc"
fi

# zsh (mac)
if [ -f "$HOME/.zshrc" ]; then
  grep -q "source ~/dotfiles/.bash_aliases" "$HOME/.zshrc" || \
    echo "source ~/dotfiles/.bash_aliases" >> "$HOME/.zshrc"
fi



echo "Done."

echo "Run: source ~/.bashrc"
