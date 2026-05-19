#!/bin/bash
FILE="$HOME/dotfiles/command_aliases"

awk '
/^[[:space:]]*$/ { next }
/^# ── / {
    label = $0
    sub(/^# ── /, "", label)
    sub(/ ─+$/, "", label)
    printf "\n  \033[1;33m%s\033[0m\n", label
    next
}
/^#/ { next }
/^alias / {
    line = substr($0, 7)
    eq = index(line, "=")
    name = substr(line, 1, eq - 1)
    val  = substr(line, eq + 1)
    gsub(/^'"'"'|'"'"'$/, "", val)
    printf "  \033[1;32m%-16s\033[0m  %s\n", name, val
    next
}
/^[a-zA-Z_][a-zA-Z0-9_]*[[:space:]]*\(/ {
    match($0, /^[a-zA-Z_][a-zA-Z0-9_]*/)
    printf "  \033[1;32m%-16s\033[0m  [fn]\n", substr($0, 1, RLENGTH) "()"
    next
}
' "$FILE"
echo
