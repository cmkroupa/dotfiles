#!/usr/bin/env bash
command -v lazygit &>/dev/null && { echo "  lazygit already installed"; exit 0; }

version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" \
  | grep '"tag_name"' | sed -E 's/.*"v([^"]+)".*/\1/')
curl -Lo /tmp/lazygit.tar.gz \
  "https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz"
tar -xzf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit /usr/local/bin/lazygit
rm /tmp/lazygit.tar.gz /tmp/lazygit
echo "  lazygit installed"
