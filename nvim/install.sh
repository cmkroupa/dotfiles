#!/usr/bin/env bash
command -v lazygit &>/dev/null && { echo "  lazygit already installed"; exit 0; }

version=$(curl -fsSL "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
  | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
[[ -z "$version" ]] && { echo "Error: could not determine lazygit version"; exit 1; }

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

curl -fLo /tmp/lazygit.tar.gz \
  "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_${os}_${arch}.tar.gz"
tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit /usr/local/bin/lazygit
rm /tmp/lazygit.tar.gz /tmp/lazygit
echo "  lazygit installed"
