alias ll="ls -laF"
alias g='git'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias home='cd ~'
alias dotfiles='cd ~/dotfiles'

alias rm='rm -i'
alias mv='mv -i'

alias gst='git status'
alias ga='git add'
alias gc='git commit -m'
alias gb='git branch'
alias gsw='git switch'

gl() {
  git log --oneline -${1:-10}
}

glg() {
  git log --oneline --graph --decorate -${1:-20}
}

alias v='nvim'
alias vi='nvim'
alias vim='nvim'

alias cls='clear'
alias reload='source ~/.bashrc'


update() {
  if command -v pacman &>/dev/null; then
    sudo pacman -Syu
  elif command -v apt &>/dev/null; then
    sudo apt update && sudo apt upgrade
  elif command -v dnf &>/dev/null; then
    sudo dnf upgrade
  elif command -v brew &>/dev/null; then
    brew update && brew upgrade
  else
    echo "no package manager found"
  fi
}

install() {
  if command -v pacman &>/dev/null; then
    sudo pacman -S "$@"
  elif command -v apt &>/dev/null; then
    sudo apt install "$@"
  elif command -v dnf &>/dev/null; then
    sudo dnf install "$@"
  elif command -v brew &>/dev/null; then
    brew install "$@"
  else
    echo "no package manager found"
  fi
}

search() {
  if command -v pacman &>/dev/null; then
    pacman -Ss "$@"
  elif command -v apt &>/dev/null; then
    apt search "$@"
  elif command -v dnf &>/dev/null; then
    dnf search "$@"
  elif command -v brew &>/dev/null; then
    brew search "$@"
  else
    echo "no package manager found"
  fi
}
