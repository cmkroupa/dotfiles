#!/usr/bin/env bash
command -v starship &>/dev/null && { echo "  starship already installed"; exit 0; }
curl -fsSL https://starship.rs/install.sh | sh -s -- --yes
