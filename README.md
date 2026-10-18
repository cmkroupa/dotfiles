# dotfiles

Personal dotfiles for macOS and Ubuntu, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Usage

```sh
git clone https://github.com/ckroupa/dotfiles ~/dotfiles
cd ~/dotfiles
./bootstrap
```

Needs Homebrew on macOS or apt on Ubuntu. On Ubuntu before 24.04, apt has no eza, so bootstrap skips it and prints where to get it. It asks `[i]nstall  [u]ninstall  [q]uit` (one keypress), or pass the letter directly: `./bootstrap i`.

**Install** (`i`):
1. Aborts if conflicting runtime managers are found (pyenv, conda, nvm, asdf, rbenv, rvm)
2. Installs stow and every folder's `packages.txt` (or `packages.brew.txt` / `packages.apt.txt` when present)
3. Moves any files that would be overwritten into `.bak/`, then symlinks every config into `~`
4. Installs mise and runs `mise install` (languages, Rails, and the CLI tools)
5. Makes zsh your login shell if it isn't already

It's safe to rerun. Everything it installs is recorded in `.bak/installed`.

**Uninstall** (`u`, asks to confirm): unlinks every config, puts back the files that were moved into `.bak/`, and removes only what install added. Anything you already had stays, and so does your login shell.

## What's in here

| Folder | Config for | Installs |
|--------|------------|----------|
| `shell` | shared aliases and `keys` | eza |
| `zsh` | `.zshrc` | zsh, zsh-syntax-highlighting, zsh-autosuggestions |
| `starship` | prompt | config only (starship comes from mise) |
| `tmux` | `.tmux.conf` | tmux |
| `mise` | languages and CLI tools | mise, then everything in `mise/.config/mise/config.toml`: node, python, ruby + rails, neovim, fzf, ripgrep, fd, bat, zoxide, starship, lazygit |
| `nvim` | neovim config | Ubuntu only: build tools and wl-clipboard |
| `ghostty` | terminal emulator | config only |

CLI tools go in the mise config so macOS and Ubuntu get the same versions; brew/apt is only for what mise can't provide.

To add a config, put it in a folder that mirrors its path under `~`, and add that folder to `PACKAGES` in `bootstrap`.
