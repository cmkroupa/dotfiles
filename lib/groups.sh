# Group definitions — coupled packages are always installed/stowed together.
# Edit here to change groupings; install.sh and link.sh both source this file.

(( BASH_VERSINFO[0] >= 4 )) || { echo "Error: bash 4+ required (current: $BASH_VERSION)" >&2; exit 1; }

declare -A PKG_GROUPS=(
  [shell]="shell zsh bash"
  [starship]="starship"
  [tmux]="tmux"
  [dev]="mise nvim"
  [gui]="ghostty"
)
PKG_GROUP_ORDER=(shell starship tmux dev gui)
