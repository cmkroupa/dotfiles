#!/usr/bin/env bash
command -v mise &>/dev/null && { echo "  mise already installed"; exit 0; }
curl https://mise.run | sh
