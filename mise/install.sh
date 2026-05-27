#!/usr/bin/env bash
command -v mise &>/dev/null && { echo "  mise already installed"; exit 0; }
curl -fsSL https://mise.run | sh
