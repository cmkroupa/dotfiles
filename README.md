# dotfiles

Personal dotfiles for macOS, Ubuntu and Fedora, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Usage

```sh
git clone https://github.com/cmkroupa/dotfiles ~/dotfiles
cd ~/dotfiles
./bootstrap
```

Needs Homebrew on macOS, apt on Ubuntu or dnf on Fedora. On Ubuntu before 24.04, apt has no eza, so bootstrap skips it and prints where to get it. It asks `[i]nstall  [u]ninstall  [q]uit` (one keypress), or pass the letter directly: `./bootstrap i`.

**Profiles:** install asks `[f]ull` or `[t]erminal only`, or pass it: `./bootstrap i terminal`. Terminal skips ghostty and Docker; full is everything.

**Install** (`i`):
1. Aborts if conflicting runtime managers are found (pyenv, conda, nvm, asdf, rbenv, rvm)
2. Installs stow and every folder's `packages.txt` (or `packages.brew.txt` / `packages.apt.txt` / `packages.dnf.txt` when present)
3. Moves any files that would be overwritten into `.bak/`, then symlinks every config into `~`
4. Installs mise and runs `mise install` (languages, Rails, and the CLI tools)
5. Full profile only: sets up Docker (adds you to the `docker` group on Linux; on macOS run `colima start`)

It's safe to rerun. Everything it installs is recorded in `.bak/installed`.

**Uninstall** (`u`, asks to confirm): unlinks every config, puts back the files that were moved into `.bak/`, and removes only what install added. Anything you already had stays.

## What's in here

| Folder | Config for | Installs |
|--------|------------|----------|
| `shell` | shared aliases, `keys`, `update` | eza, btop |
| `zsh` | `.zshrc`, `.zprofile` | zsh, zsh-syntax-highlighting, zsh-autosuggestions |
| `starship` | prompt | config only (starship comes from mise) |
| `tmux` | `.tmux.conf` | tmux |
| `mise` | languages and CLI tools | mise, then everything in `mise/.config/mise/config.toml`: node, python, ruby + rails, neovim, fzf, ripgrep, fd, bat, zoxide, starship, lazygit, lazydocker |
| `nvim` | neovim config | Linux only: build tools and wl-clipboard |
| `ghostty` | terminal emulator | config only (full profile) |
| `docker` | no config | full profile: docker, docker-compose, colima (macOS); docker.io, docker-compose-v2 (Ubuntu); moby-engine, docker-compose (Fedora) |

CLI tools go in the mise config so macOS and Linux get the same versions; brew/apt/dnf is only for what mise can't provide.

To add a config, put it in a folder that mirrors its path under `~`, and add that folder to `ALL_PACKAGES` in `bootstrap` (and to the terminal profile in `choose_profile` if it belongs there).
