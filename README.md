# dotfiles

Personal configuration files and scripts for macOS and Linux (Arch/Manjaro).

## Quick start

```bash
git clone git@github.com:jtprince/dotfiles.git ~/dotfiles
cd ~/dotfiles

# Preview symlink changes
dotfiles-configure --dry

# Apply symlinks
dotfiles-configure
```

`dotfiles-configure` is idempotent — rerun it any time you update the repo.

## Repository layout

```
config/              App configs, symlinked into ~/.config (or ~/)
  mac/               macOS-only (amethyst, hammerspoon, karabiner, skhd, osascript)
  linux/             Linux-only (sway, waybar, X11, GTK, audio, etc.)
  _archive/          Configs for tools no longer in use
  <name>/            Cross-platform configs (git, kitty, nvim, zsh, …)
bin/                 Executable scripts, symlinked as ~/bin and on $PATH
  data/              Data conversion (csv, json, parquet, etc.)
  docker/            Docker management
  git/               Git utilities
  markdown/          Markdown conversion
  media/             Image, PDF, audio/video conversion
  python/            Python/Jupyter tooling
  pyenv/             Pyenv/virtualenv helpers
  work/              Work-specific scripts
  aliases/           Shell aliases (short command wrappers)
  _archive/          Old/unused scripts (kept for reference)
scripts/             One-off or infrequent scripts (not on $PATH)
```

## Platform support

Both macOS and Linux are actively supported. `dotfiles-configure` detects the
platform and creates the appropriate symlinks. Platform-specific options:

- **macOS**: Homebrew, Amethyst, Hammerspoon, Karabiner-Elements
- **Linux**: Sway/i3, Waybar, PipeWire, X11 resolution profiles

Linux-only flags: `-r/--resolution {4k,hd,mid}`, `-d/--display-server {x11,wayland}`

## Key tools

- **Shell**: zsh with [sheldon](https://github.com/rossmacarthur/sheldon) (plugins) and [starship](https://starship.rs/) (prompt)
- **Editor**: Neovim (lazy.nvim)
- **Terminal**: kitty
- **Linting**: ruff (Python), pre-commit hooks

## Adding a new config

1. Place the config in `config/<name>/` (or `config/mac/` / `config/linux/` if platform-specific)
2. Add the entry to the appropriate list in `bin/dotfiles-configure`
3. Run `dotfiles-configure` to create the symlink

## Maintenance

```bash
# Remove dangling symlinks in ~/.config
dotfiles-configure --clean-broken

# Run linters before committing
pre-commit run --all-files
```
