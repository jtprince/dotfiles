# nvim session management

Plugin: **folke/persistence.nvim** (`lua/plugins/editor.lua`)

## How it's configured right now

Sessions are keyed to **project root + git branch** (auto-detected at startup).

Project root is the innermost ancestor directory containing:
`.git`, `pyproject.toml`, `package.json`, `Cargo.toml`, `go.mod`

On every `nvim` launch (with or without file args):
1. Detects project root from the first arg or cwd
2. `cd`s to that root (so telescope, oil, etc. are scoped to the project)
3. Auto-restores the saved session for that root + branch
4. Shows `Session: ~/projects/my-project` in the notification area

Sessions auto-save on exit (whenever ≥1 buffer is open).

## Keymaps (`<leader>` = `,`)

| Key      | Action                                      |
|----------|---------------------------------------------|
| `,qs`    | Load session for cwd (manual re-load)       |
| `,qS`    | Pick a session from a list (Telescope)      |
| `,ql`    | Load the last session (across all projects) |
| `,qd`    | Stop saving — current session won't be overwritten on exit |

## Typical flows

**Normal use** — just open nvim:
```
cd ~/projects/ms-toolkit
nvim                      # restores session for ms-toolkit/main
```

**Open a specific file from anywhere:**
```
nvim ~/projects/ms-toolkit/src/foo.py   # restores ms-toolkit session, then opens foo.py
```

**Start fresh without clobbering the saved session:**
```
nvim
,qd                       # stop saving — then work freely
```

**Switch branches** — sessions are branch-aware:
```
git checkout feature/foo
nvim                      # loads feature/foo session (separate from main)
```

**Manually pick an old session:**
```
,qS                       # Telescope picker of all saved sessions
```

## Session files location

`~/.local/state/nvim/sessions/`  (one `.vim` file per project+branch)
