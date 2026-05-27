#!/usr/bin/env bash
set -e
command -v glow &>/dev/null && { echo "  glow already installed"; exit 0; }

version=$(curl -fsSL "https://api.github.com/repos/charmbracelet/glow/releases/latest" \
  | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
[[ -z "$version" ]] && { echo "Error: could not determine glow version"; exit 1; }

case "$(uname -s)" in
  Linux)  os=Linux ;;
  Darwin) os=Darwin ;;
  *)      echo "Error: unsupported OS: $(uname -s)"; exit 1 ;;
esac

case "$(uname -m)" in
  x86_64)        arch=x86_64 ;;
  arm64|aarch64) arch=arm64 ;;
  *)             echo "Error: unsupported arch: $(uname -m)"; exit 1 ;;
esac

mkdir -p /tmp/glow_tmp
curl -fLo /tmp/glow.tar.gz \
  "https://github.com/charmbracelet/glow/releases/download/v${version}/glow_${version}_${os}_${arch}.tar.gz"
tar -xzf /tmp/glow.tar.gz -C /tmp/glow_tmp
glow_bin=$(find /tmp/glow_tmp -type f -name 'glow' | head -1)
[[ -z "$glow_bin" ]] && { echo "Error: glow binary not found in archive"; exit 1; }
sudo install "$glow_bin" /usr/local/bin/glow
rm -rf /tmp/glow.tar.gz /tmp/glow_tmp
echo "  glow installed"
