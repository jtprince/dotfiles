# AGENTS.md

## Overview

This is a personal dotfiles repository. It contains configuration files, shell
scripts, and utilities for a development environment that targets both **macOS**
and **Linux (Manjaro/Arch)**. All configs should be cross-platform compatible
wherever possible; use platform detection (`uname`, `$OSTYPE`, etc.) when
behaviour must diverge.

## Repository layout

```
config/            App configs, symlinked into ~/.config (or ~/) by dotfiles-configure
  mac/             macOS-only configs (amethyst, hammerspoon, karabiner, skhd, osascript)
  linux/           Linux-only configs (sway, waybar, X11, GTK, audio, etc.)
  _archive/        Archived configs for tools no longer in use
  <name>/          Cross-platform configs (git, kitty, nvim, zsh, tmux, …)
bin/               Executable scripts, symlinked to ~/bin and expected on $PATH
  data/            Data format conversion (csv, json, parquet, etc.)
  docker/          Docker management
  git/             Git utilities
  markdown/        Markdown conversion
  media/           Image, PDF, audio/video conversion
  python/          Python/Jupyter tooling
  work/            Work-specific scripts
  aliases/         Shell aliases
  _archive/        Old/unused scripts
scripts/           One-off or infrequent scripts (not on $PATH)
```

- `bin/dotfiles-configure` is a Python script that idempotently creates symlinks
  from this repo into the home directory. Run with `--dry` to preview changes.
- Neovim config lives in `config/nvim/` and uses **lazy.nvim** as the plugin
  manager.
- Shell config (zsh) lives in `config/zsh/`.
- Git config lives in `config/git/`.

## Git policy

**Unless it is essential for a series of branch related commits/changes and you
are on autopilot, do NOT EVER commit or push any code to git/github UNLESS the
user has specifically asked for this or you have requested permission for it
first.**

## Coding conventions

- **Shell scripts**: Use `#!/usr/bin/env bash` (or `zsh` where needed). Prefer
  POSIX-compatible constructs when practical; use bashisms only when they
  meaningfully improve clarity or safety.
- **Python scripts**: The repo uses `ruff` for linting/formatting (see
  `.pre-commit-config.yaml`). Follow existing style in the file you are editing.
- **Neovim/Lua**: Follow the style of the existing `init.lua`. Lazy-load
  plugins where possible (`ft`, `cmd`, `keys`, `event`).
- Keep scripts small and focused. Prefer composable tools over monoliths.
- Use `pre-commit` hooks (already configured) before committing: `pre-commit run --all-files`.

## Cross-platform notes

- On macOS the window manager helpers are Amethyst/skhd/Hammerspoon; on Linux
  they are Sway/i3.
- Package management: `brew` on macOS, `pacman`/`yay` on Arch.
- Paths like `~/Dropbox/env` may hold secrets or machine-local overrides and are
  **not** checked into this repo.
- Linux-only configs live under `config/linux/` (Xresources, GTK themes, Sway,
  Waybar, etc.). macOS-only configs live under `config/mac/` (Hammerspoon,
  Karabiner, Amethyst, skhd, osascript).

## Testing changes

There is no automated test suite. Validate changes by:

1. Running `dotfiles-configure --dry` to verify symlink changes.
2. Sourcing the relevant config (e.g., `source ~/.zshrc`) or restarting the
   target application.
3. Running `pre-commit run --all-files` to check linting before any commit.
