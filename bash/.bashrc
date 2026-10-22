# Interactive bash hands off to zsh, where all the config lives (.zshrc)
case $- in
*i*) command -v zsh >/dev/null && exec zsh ;;
esac
