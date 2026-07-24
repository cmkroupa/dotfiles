# dotfiles

Personal dotfiles managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Requirements

- git
- stow (`sudo apt install stow`)
- cargo

## Install

Run once on a new machine:

```sh
git clone https://github.com/ckroupa/dotfiles ~/dotfiles
cd ~/dotfiles
cargo install --path .
dot install
```

After `cargo install --path .`, `dot` can run from anywhere. It uses `DOTFILES_DIR` when set, otherwise it looks from the current directory upward and then falls back to `~/dotfiles`.

This will:
1. Detect your OS and package manager
2. Abort if conflicting runtime managers are found (pyenv, conda, nvm, asdf, rbenv, rvm)
3. Install all packages via apt/brew/pacman/dnf
4. Symlink everything into `~` via stow
5. Run Rust package installers for mise, Rails, glow, lazygit, and starship

## Link

```sh
dot link
```

Relinks selected package groups without installing packages or running custom installers.

## Uninstall

```sh
dot uninstall
```

Removes managed symlinks and restores files previously moved into `.bak/<package>/`.

## Scripts

| Script | Purpose |
|--------|---------|
| `Cargo.toml` / `src/` | Rust CLI that owns install, link, uninstall, package groups, and Stow logic |

## Groups

Packages are organized into groups. Selecting a group links all members together.

| Group | Packages | What it sets up |
|-------|----------|-----------------|
| `terminal` | shell, zsh, bash, starship, tmux | shells, shared aliases, prompt, terminal multiplexer |
| `nvim` | mise, nvim | runtime version manager and editor config |
| `gui` | ghostty | terminal emulator config |

To change groupings, edit `GROUPS` in `src/config.rs`. Group-specific installer code lives in `src/install/terminal.rs`, `src/install/nvim.rs`, and `src/install/gui.rs`.

## What gets installed

| Group | Installed via |
|-------|--------------|
| terminal | zsh, fzf, zoxide, zsh-syntax-highlighting, zsh-autosuggestions, bat, eza, fd, glow, starship, tmux |
| nvim | neovim, ripgrep, lazygit, mise, Ruby via mise, Rails via gem |
| gui | ghostty config only |

## Conflicts

Before Stow linking, conflicting files are moved into `.bak/<package>/`. `dot uninstall` restores those backups after unstowing.
