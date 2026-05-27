# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Requirements

- bash 4+
- git
- stow (`sudo apt install stow`)

## Install

Run once on a new machine:

```sh
git clone https://github.com/ckroupa/dotfiles ~/dotfiles
cd ~/dotfiles
./install.sh
```

This will:
1. Detect your OS and package manager
2. Abort if conflicting runtime managers are found (pyenv, conda, nvm, asdf, rbenv, rvm)
3. Install all packages via apt/brew/pacman/dnf
4. Run per-package install scripts (mise, glow, lazygit, starship)
5. Symlink everything into `~` via stow

## Uninstall

```sh
./uninstall.sh
```

Removes all symlinks and restores any files that were backed up before linking.

## Scripts

| Script | Purpose |
|--------|---------|
| `install.sh` | Full setup — install packages and symlink dotfiles |
| `uninstall.sh` | Remove symlinks and restore backed-up files |
| `lib/link.sh` | Internal — called by install.sh to stow packages |
| `lib/groups.sh` | Internal — defines which stow packages belong together |

## Groups

Packages are organized into groups. Selecting a group links all members together.

| Group | Packages | What it sets up |
|-------|----------|-----------------|
| `shell` | shell, zsh, bash | zshrc, bashrc, shared aliases |
| `starship` | starship | cross-shell prompt |
| `tmux` | tmux | terminal multiplexer |
| `dev` | mise, nvim | runtime version manager + editor |

To change groupings, edit `lib/groups.sh`.

## What gets installed

| Group | Installed via |
|-------|--------------|
| shell | zsh, fzf, zoxide, zsh-syntax-highlighting, zsh-autosuggestions, bat, eza, fd, glow (binary) |
| starship | curl from starship.rs |
| tmux | tmux |
| dev | neovim, ripgrep (apt), lazygit + mise (binaries) |

## Backups

Before symlinking, `lib/link.sh` moves any conflicting files into `.bak/<package>/`. Running `uninstall.sh` restores them.
