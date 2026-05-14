#!/bin/bash
# Sourced by setup.sh and sub-scripts. Sets $OS to: mac | arch | ubuntu

if [[ "$OSTYPE" == "darwin"* ]]; then
  OS="mac"
elif [[ -f /etc/arch-release ]]; then
  OS="arch"
elif grep -qi "ubuntu\|debian" /etc/os-release 2>/dev/null; then
  OS="ubuntu"
else
  echo "Unsupported OS. Supported: macOS, Ubuntu/Debian, Arch Linux."
  exit 1
fi
echo "Detected OS: $OS"
