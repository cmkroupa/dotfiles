#!/bin/bash
FILE="$DOTFILES/config/aliases"

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
    name = substr($0, 1, RLENGTH) "()"
    desc = ""
    idx = index($0, "#")
    if (idx > 0) {
        desc = substr($0, idx + 1)
        gsub(/^[[:space:]]+|[[:space:]]+$/, "", desc)
    }
    if (desc == "") {
        desc = "[fn]"
    }
    printf "  \033[1;32m%-16s\033[0m  %s\n", name, desc
    next
}
' "$FILE"
echo
