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

alias path='echo $PATH | tr ":" "\n"'

alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -'


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


weather() {
  curl "wttr.in/${1:-Toronto}?format=3"
}
weatherfull() {
  curl "wttr.in/${1:-Toronto}"
}

explain() {
  curl "cheat.sh/$1"
}

randpword() {
  tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c ${1:-20}; echo
}

copyfile() {
  cat "$1" | wl-copy
}

mkcd() {
  mkdir -p "$1" && cd "$1"
}

extract() {
  case "$1" in
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.bz2) tar xjf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.gz)      gunzip "$1" ;;
    *.rar)     unrar x "$1" ;;
    *.7z)      7z x "$1" ;;
    *)         echo "unknown archive format" ;;
  esac
}

dload() {
  curl -L --progress-bar -O "$1"
}
# usage: dload https://example.com/file.zip

ask() {
  curl -s http://localhost:11434/api/generate \
    -d "{\"model\": \"qwen2.5-coder:14b\", \"prompt\": \"$*\", \"stream\": false}" \
    | python3 -c "import sys,json; print(json.load(sys.stdin)['response'])"
}
