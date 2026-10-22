# dotfiles

Personal dotfiles for macOS, Ubuntu and Fedora, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Usage

```sh
git clone https://github.com/cmkroupa/dotfiles ~/dotfiles
cd ~/dotfiles
./bootstrap
```

Needs Homebrew on macOS, apt on Ubuntu or dnf on Fedora. On Ubuntu before 24.04, apt has no eza, so bootstrap skips it and prints where to get it. Run `./bootstrap` for a menu (one keypress), or pass the choice: `./bootstrap h`, `i` or `u`.

| Choice | Does |
|--------|------|
| `h` headless | terminal tools only: zsh + plugins, starship, tmux, eza, btop, mise, node, neovim, fzf, ripgrep, fd, bat, zoxide, lazygit |
| `i` install | everything in headless, plus bun, python, ruby + rails, lua, Docker (+ lazydocker) and the Ghostty config |
| `u` uninstall | see below |

**Install** (`h` or `i`):
1. Aborts if conflicting runtime managers are found (pyenv, conda, nvm, asdf, rbenv, rvm)
2. Installs stow and each included folder's `packages.txt` (or `packages.brew.txt` / `packages.apt.txt` / `packages.dnf.txt` when present)
3. Moves any files that would be overwritten into `.bak/`, then symlinks each included config into `~`
4. Installs mise and runs `mise install` for the included tools
5. `i` only: sets up Docker (adds you to the `docker` group on Linux; on macOS run `colima start`)

It's safe to rerun. Everything it installs is recorded in `.bak/installed`.

**Uninstall** (`u`, asks to confirm): unlinks every config, puts back the files that were moved into `.bak/`, and removes only what install added. Anything you already had stays.

## What's in here

| Folder | Config for | Installs |
|--------|------------|----------|
| `bash` | `.bashrc` | nothing; starts zsh from interactive bash, so you needn't change your login shell |
| `shell` | shared aliases, `keys`, `update` | eza, btop |
| `zsh` | `.zshrc`, `.zprofile` | zsh, zsh-syntax-highlighting, zsh-autosuggestions |
| `starship` | prompt | config only (starship comes from mise) |
| `tmux` | `.tmux.conf` | tmux |
| `mise` | CLI tools | mise, then `mise/.config/mise/config.toml`: node, neovim, fzf, ripgrep, fd, bat, zoxide, starship, lazygit |
| `nvim` | neovim config | Linux only: build tools, unzip and wl-clipboard |
| `languages` | python packages, mise languages (`i` only) | bun, python, ruby + rails, lua; Linux build libraries |
| `docker` | mise's lazydocker (`i` only) | docker, docker-compose, colima (macOS); docker.io, docker-compose-v2 (Ubuntu); moby-engine, docker-compose (Fedora) |
| `ghostty` | terminal emulator (`i` only) | config only |

CLI tools go in the mise config so macOS and Linux get the same versions; brew/apt/dnf is only for what mise can't provide.

To add a config, put it in a folder that mirrors its path under `~`, and add that folder to `ALL_PACKAGES` in `bootstrap` (and to `TERMINAL_PACKAGES` if headless should get it).
