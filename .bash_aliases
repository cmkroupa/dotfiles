alias ll="ls -laF"
alias g='git'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias home='cd ~'
alias dotfiles='cd ~/dotfiles'

alias rm='trash'
alias rmforce='rm -rf'

alias gst='git status'
alias gad='git add'
alias gcm='git commit -m'
alias gph='git push'
alias gfh='git fetch'
alias gbr='git branch'
alias gsw='git switch'

alias v='nvim'
alias vi='nvim'
alias vim='nvim'

alias cls='clear'
alias reload='source ~/.bashrc'

alias rg='rg --smart-case'                   
alias rgf='rg --files | rg'                

gl() {
  git log --oneline -${1:-10}
}

glg() {
  git log --oneline --graph --decorate -${1:-20}
}

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
    sudo pacman -S --noconfirm "$@"
  elif command -v apt &>/dev/null; then
    sudo apt install -y "$@"
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y "$@"
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

remove() {
  if command -v pacman &>/dev/null; then
    sudo pacman -Rns "$@"
  elif command -v apt &>/dev/null; then
    sudo apt remove -y "$@"
  elif command -v dnf &>/dev/null; then
    sudo dnf remove -y "$@"
  elif command -v brew &>/dev/null; then
    brew uninstall "$@"
  else
    echo "no package manager found"
  fi
}

