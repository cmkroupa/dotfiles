#!/usr/bin/env bash
set -e
command -v mise &>/dev/null || { echo "mise not found — install mise first"; exit 1; }
mise install ruby
mise exec ruby -- gem install ruby-lsp rubocop --no-document
echo "  ruby gems installed"
