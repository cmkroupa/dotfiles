alias ll="ls -laF"
alias g='git'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias home='cd ~'
alias dotfiles='cd ~/dotfiles'

alias rm='trash'
alias rmforce='/bin/rm -rf'
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

reload() {
  if [ -n "$ZSH_VERSION" ]; then
    source ~/.zshrc
    echo "Zsh config reloaded."
  elif [ -n "$BASH_VERSION" ]; then
    source ~/.bashrc
    echo "Bash config reloaded."
  else
    echo "Unknown shell. Could not reload."
  fi
}

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
WEATHER() {
  curl "wttr.in/${1:-Toronto}"
}

explain() {
  curl "cheat.sh/$1"
}

pword() {
  tr -dc 'A-Za-z0-9!@#$%^&*' < /dev/urandom | head -c ${1:-20}; echo
}


mkcd() {
  mkdir -p "$1" && cd "$1"
}

copyfile() {
  if [ -z "$1" ]; then
    echo "Usage: copyfile <filename>"
    return 1
  fi

  if [ ! -f "$1" ]; then
    echo "Error: File '$1' not found."
    return 1
  fi

  if command -v pbcopy &>/dev/null; then
    cat "$1" | pbcopy
    echo "Copied '$1' to macOS clipboard."
  elif command -v wl-copy &>/dev/null; then
    cat "$1" | wl-copy
    echo "Copied '$1' to Wayland clipboard."
  elif command -v xclip &>/dev/null; then
    cat "$1" | xclip -selection clipboard
    echo "Copied '$1' to X11 clipboard."
  else
    echo "Error: No clipboard tool found."
    return 1
  fi
}

extract() {
  if [ -f "$1" ]; then
    case "$1" in
      *.tar.bz2|*.tar.gz|*.tar.xz|*.tbz2|*.tgz|*.txz|*.tar) tar xf "$1" ;;
      *.zip)       unzip "$1" ;;
      *.rar)       unrar x "$1" ;;
      *.7z)        7z x "$1" ;;
      *)           echo "'$1' cannot be extracted via extract()" ;;
    esac
  else
    echo "'$1' is not a valid file"
  fi
}

dload() {
  curl -L -C - -J --progress-bar -O "$1"
}


ask() {
  curl -s http://localhost:11434/api/generate \
    -d "{\"model\": \"qwen2.5-coder:14b\", \"prompt\": \"$*\", \"stream\": true}" | \
    jq -rj '.response // .error'
}

