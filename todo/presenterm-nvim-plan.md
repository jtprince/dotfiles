# presenterm.nvim — implementation plan

A Neovim integration that does for [`presenterm`](https://github.com/mfontanini/presenterm) what `:MarkdownPreview` does for browsers: spawn a side-by-side terminal slideshow that hot-reloads on save, with optional cursor → slide sync.

This document is a self-contained spec — enough detail to pick up cold and implement.

---

## 1. Goals

| # | Goal | Status in plan |
|---|------|----------------|
| 1 | `:Presenterm` opens a new terminal window running `presenterm <current-buffer>`. | MVP |
| 2 | Edits in nvim auto-reflect in the slideshow. | Free — presenterm watches the file. |
| 3 | Cursor in nvim → presenterm jumps to matching slide. | Stretch, included. |
| 4 | `:PresentermStop` cleanly closes the spawned window. | MVP |
| 5 | Don't orphan presenterm processes on `:q`. | MVP |

User decisions captured (asked during planning):
- Sync **enabled by default**.
- **One session per buffer** (each markdown buffer can drive its own window).
- Count all three separator types: `<!-- end_slide -->` always; `---` and H1 mirrored from user's presenterm config.

---

## 2. Environment & feasibility

| Fact | Source |
|------|--------|
| presenterm 0.16.1 installed (`/opt/homebrew/bin/presenterm`). | `presenterm --version` |
| presenterm has hot-reload on file change (built-in). | Behaviour |
| presenterm binds `<number>G` to "go to slide N". | `config.sample.yaml` `bindings.go_to_slide: ["<number>G"]` |
| presenterm exposes a TCP pub/sub for speaker notes (`127.0.0.1:59418` default). | `config.sample.yaml` `speaker_notes` block |
| User runs nvim inside kitty (`KITTY_WINDOW_ID=36`, `TERM=xterm-kitty`). | `env` |
| kitty has `allow_remote_control yes`, `listen_on none`. | `config/kitty/kitty.common.conf:180-181` |
| `kitty @ launch` from inside kitty works without a UDS socket (process-based RC). | kitty docs |
| nvim plugin manager is native `vim.pack`. Standalone modules live in `lua/config/<name>.lua`. | `config/nvim/init.lua:20-25`, `config/nvim/lua/config/markdown_gmail.lua` |
| Leader is `,`. `<leader>m*` mostly free (only `<leader>mm` = minimap). | `config/nvim/init.lua:17`, `config/nvim/lua/plugins/editor.lua` |

**Sync route chosen:** keystroke injection via `kitty @ send-text "<N>G"`. Simpler than reverse-engineering the speaker-notes wire protocol, and the `go_to_slide` binding is stable.

---

## 3. Files

| File | Action | Purpose |
|------|--------|---------|
| `config/nvim/lua/config/presenterm.lua` | NEW | Module: spawn / sync / stop. ~180 lines. |
| `config/nvim/ftplugin/markdown.lua` | NEW | Buffer-local keymaps. ~15 lines. |
| `config/nvim/init.lua` | EDIT | Add `require("config.presenterm")` after line 25 (next to the existing `require("config.markdown_gmail")`). |

No GitHub-sourced plugin is needed. Pattern matches `markdown_gmail.lua`.

---

## 4. User-facing API

| Command | Behavior |
|---------|----------|
| `:Presenterm` | Start session for the current buffer. Auto-saves first if modified. No-op if already running for this buffer (notify). |
| `:PresentermStop` | Stop session for the current buffer's file. Best-effort window close. |
| `:PresentermToggle` | Convenience. |
| `:PresentermSyncToggle` | Toggle cursor → slide sync for the current buffer's session (sync starts ON). |

**Keymaps** (in `ftplugin/markdown.lua`, buffer-local on filetype=markdown):

| Key | Action |
|-----|--------|
| `<leader>mp` | `:Presenterm` |
| `<leader>mP` | `:PresentermStop` |
| `<leader>ms` | `:PresentermSyncToggle` |

(`<leader>mm` is taken by minimap; `<leader>mp/mP/ms` are free.)

---

## 5. Module design (`lua/config/presenterm.lua`)

### State

```lua
M.sessions = {}  -- bufnr -> session
-- session = {
--   window_id      = "12",                        -- kitty window id
--   file           = "/abs/path/to/buffer.md",
--   last_slide     = 1,                           -- last slide we asked presenterm to show
--   debounce_timer = uv_timer | nil,
--   sync_enabled   = true,
--   augroup_id     = <int>,                       -- cleanup target
--   count_rules    = { end_slide=true, thematic_break=false, implicit_h1=false },
-- }
```

### Lifecycle

```lua
function M.start(bufnr)
  -- 1. Validate:
  --    - bufnr's filetype == "markdown"
  --    - vim.fn.expand("%:p") not empty
  --    - vim.fn.executable("presenterm") == 1
  --    - vim.env.KITTY_WINDOW_ID set
  --    - vim.fn.executable("kitty") == 1
  --    - sessions[bufnr] not already set
  -- 2. If buffer modified, vim.cmd.write()
  -- 3. count_rules = read_presenterm_config()  (see §6)
  -- 4. Spawn:
  --      vim.system({
  --        "kitty","@","launch",
  --        "--type=os-window",
  --        "--cwd=current",
  --        "--title=presenterm: " .. vim.fn.fnamemodify(file, ":t"),
  --        "--copy-env",
  --        "presenterm", file,
  --      }, { text = true }):wait()
  --    Capture stdout (kitty prints the new window-id). Trim whitespace.
  -- 5. Persist session.
  -- 6. Register augroup `presenterm_<bufnr>`:
  --      CursorMoved/CursorHold/InsertLeave (buffer-scoped) -> on_cursor_move(bufnr)
  --      BufWritePost (buffer-scoped)                       -> on_save(bufnr)         [no-op currently; file watch already handles]
  --      BufUnload    (buffer-scoped)                       -> M.stop(bufnr)
  -- 7. Register VimLeavePre once globally to stop all sessions on quit.
  -- 8. Initial sync: send `1G` so presenterm starts at slide computed from cursor.
end

function M.stop(bufnr)
  local s = M.sessions[bufnr]
  if not s then return end
  if s.debounce_timer then s.debounce_timer:stop(); s.debounce_timer:close() end
  pcall(vim.system, {"kitty","@","close-window","--match","id:"..s.window_id}, { text = true }):wait()
  vim.api.nvim_del_augroup_by_id(s.augroup_id)
  M.sessions[bufnr] = nil
end

function M.toggle_sync(bufnr)
  local s = M.sessions[bufnr]
  if not s then vim.notify("Presenterm: no active session", vim.log.levels.WARN); return end
  s.sync_enabled = not s.sync_enabled
  vim.notify("Presenterm sync " .. (s.sync_enabled and "ON" or "OFF"))
end
```

### Cursor → slide

```lua
local function on_cursor_move(bufnr)
  local s = M.sessions[bufnr]
  if not s or not s.sync_enabled then return end
  if s.debounce_timer then s.debounce_timer:stop() end
  s.debounce_timer = vim.defer_fn(function()
    local row = vim.api.nvim_win_get_cursor(0)[1]
    local slide = compute_slide(bufnr, row, s.count_rules)
    if slide == s.last_slide then return end
    s.last_slide = slide
    vim.system({
      "kitty","@","send-text",
      "--match","id:"..s.window_id,
      tostring(slide).."G",
    })  -- fire and forget
  end, 150)
end
```

`vim.system` without `:wait()` is non-blocking. `kitty @ send-text` sends literal characters into the target window's pty; presenterm's `<number>G` binding consumes the digits and jumps.

---

## 6. Slide counting

### 6.1 Read presenterm config

Lookup order:
1. `$PRESENTERM_CONFIG_FILE`
2. `$XDG_CONFIG_HOME/presenterm/config.yaml`
3. `~/.config/presenterm/config.yaml`
4. Defaults (both flags `false`).

Parse only the two booleans we care about (line-regex; no YAML library):

```lua
local function read_presenterm_config()
  local path = vim.env.PRESENTERM_CONFIG_FILE
            or (vim.env.XDG_CONFIG_HOME or vim.fn.expand("~/.config")) .. "/presenterm/config.yaml"
  local rules = { end_slide = true, thematic_break = false, implicit_h1 = false }
  local override = vim.g.presenterm_separators
  if type(override) == "table" then return vim.tbl_extend("force", rules, override) end
  if vim.fn.filereadable(path) ~= 1 then return rules end
  for _, line in ipairs(vim.fn.readfile(path)) do
    local k, v = line:match("^%s*(end_slide_shorthand)%s*:%s*(%a+)")
    if k and v then rules.thematic_break = v == "true" end
    k, v = line:match("^%s*(implicit_slide_ends)%s*:%s*(%a+)")
    if k and v then rules.implicit_h1 = v == "true" end
  end
  return rules
end
```

Caveat: this is regex on a YAML file. It works for the standard top-level `options:` block (the only place these keys appear) but doesn't handle nested overrides or YAML anchors. Acceptable; document the override flag as the escape hatch.

### 6.2 Counter

```lua
local function compute_slide(bufnr, row, rules)
  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, row, false)
  local count = 0
  local in_fence = false
  local in_frontmatter = false
  local seen_first_h1 = false

  for i, line in ipairs(lines) do
    -- frontmatter at file top
    if i == 1 and line:match("^%-%-%-%s*$") then
      in_frontmatter = true
    elseif in_frontmatter and line:match("^%-%-%-%s*$") then
      in_frontmatter = false
    elseif not in_frontmatter then
      -- track fenced code
      if line:match("^%s*```") or line:match("^%s*~~~") then
        in_fence = not in_fence
      elseif not in_fence then
        if rules.end_slide and line:match("^%s*<!%-%-%s*end_slide%s*%-%->%s*$") then
          count = count + 1
        elseif rules.thematic_break and line:match("^%-%-%-%s*$") then
          count = count + 1
        elseif rules.implicit_h1 and line:match("^#%s") then
          if seen_first_h1 then count = count + 1 end
          seen_first_h1 = true
        end
      end
    end
  end
  return count + 1
end
```

The "skip first H1" handles the fact that slide 1 *starts* at the first H1, it doesn't end there.

---

## 7. Terminal selection (kitty MVP)

MVP supports kitty only. Detection:

```lua
local function require_kitty()
  if not vim.env.KITTY_WINDOW_ID then
    vim.notify("Presenterm: must be run inside kitty (other terminals not yet supported)", vim.log.levels.ERROR)
    return false
  end
  if vim.fn.executable("kitty") ~= 1 then
    vim.notify("Presenterm: `kitty` binary not on PATH", vim.log.levels.ERROR)
    return false
  end
  return true
end
```

### Future: WezTerm / tmux fallbacks

Stubs noted in code but unimplemented:

```
-- WezTerm:
--   spawn:    wezterm cli spawn --new-window -- presenterm <file>
--             pane_id from stdout
--   send:     wezterm cli send-text --no-paste --pane-id <id> "<N>G\n"  (presenterm needs no Enter; just digits + G)
--             actually: <N>G with no newline, since presenterm reads raw key events
--
-- tmux:
--   spawn:    tmux new-window -d -P -F "#{pane_id}" "presenterm <file>"
--   send:     tmux send-keys -t <pane> "<N>G"
--   close:    tmux kill-pane -t <pane>
```

Refactor `start/stop/sync` to dispatch through a `backend` table once a second backend is added.

---

## 8. Failure modes (explicit)

| Condition | Behavior |
|-----------|----------|
| `presenterm` not on PATH | Notify error, abort. |
| Not in kitty | Notify error with suggestion, abort. |
| Buffer not markdown | Notify error, abort. |
| Buffer never saved (no file path) | Notify error, abort. |
| `kitty @ launch` fails | Notify error with stderr, abort. |
| Window-id capture returns empty/non-numeric | Notify warning; spawn proceeded but sync disabled. Session still tracked so `:PresentermStop` works (best-effort). |
| `kitty @ send-text` fails mid-session (window closed externally) | Detect via exit code; auto-stop session, notify. |
| Same buffer `:Presenterm` twice | Notify "already running", no-op. |
| Two buffers each call `:Presenterm` | Two independent sessions. |
| `:q` while session active | `VimLeavePre` autocmd stops all sessions. |

---

## 9. Verification

### 9.1 Smoke test (independent of plugin)

Confirm the `kitty @ send-text` route works at all:

```bash
cat > /tmp/demo.md <<'EOF'
# Slide 1
First.
<!-- end_slide -->
# Slide 2
Second.
<!-- end_slide -->
# Slide 3
Third.
EOF

# Spawn presenterm in a new kitty OS window:
kitty @ launch --type=os-window presenterm /tmp/demo.md
# Note the window id printed.

# From the original kitty window:
kitty @ send-text --match id:<NEW_ID> "2G"
# EXPECT: presenterm jumps to "Slide 2".
```

If this fails, the plugin won't work — fix kitty config first.

### 9.2 Plugin end-to-end

1. `nvim /tmp/demo.md` → `:Presenterm`. New kitty OS window opens; "Slide 1" visible.
2. Move cursor below first `<!-- end_slide -->`. Within ~200ms, presenterm shows "Slide 2".
3. Move cursor below second separator → "Slide 3".
4. Append `<!-- end_slide -->` and `# Slide 4` to buffer, save → presenterm hot-reloads (built-in); cursor sync continues to work for slide 4.
5. `:PresentermSyncToggle` → moving cursor no longer jumps slides.
6. `:PresentermStop` → kitty window closes; `pgrep presenterm` empty.
7. Re-run `:Presenterm` → fresh session.
8. Open a *second* markdown buffer in nvim, `:Presenterm` there → second kitty window appears, both sessions independent.
9. Open non-markdown buffer, `:Presenterm` → error notify, no spawn.
10. `nvim` started outside kitty (Terminal.app), `:Presenterm` → clean error.
11. Quit nvim with active session(s) → all kitty windows auto-close (`VimLeavePre`).
12. Frontmatter test: file with leading `---\nfoo: bar\n---\n# Slide 1\n...` — slide 1 still slide 1 (frontmatter skipped).
13. Code-fence test: file with ` ```\n---\n``` ` inside a slide — `---` not counted (fence skip).
14. With `end_slide_shorthand: true` in `~/.config/presenterm/config.yaml`, `---` lines outside fences do count as separators (auto-detected from config).

---

## 10. Effort estimate

| Phase | Time |
|-------|------|
| MVP (spawn + hot reload + stop) | ~1h |
| Cursor sync + debounce + slide counter | ~2-3h |
| Edge cases (frontmatter, fences, multi-buffer, VimLeavePre) | ~1h |
| Manual verification (steps in §9) | ~30min |
| **Total** | **~half day for production quality** |

MVP-only (sync deferred) is demoable in under 1 hour.

---

## 11. Out of scope (future)

- WezTerm / tmux / iTerm2 backends.
- Speaker-notes IPC route (TCP `127.0.0.1:59418`) — would let us drive sync without keystroke injection and survive non-kitty terminals. Wire format needs reverse-engineering from presenterm source.
- Reverse sync: presenterm slide change → nvim cursor jump. Would consume the speaker-notes feed.
- `<!-- pause -->` step counting (sub-slide animations).
- CLI passthrough: `:Presenterm --theme dark`, `:Presenterm --enable-snippet-execution`.
- Auto-restart presenterm if the spawned process dies.
- Status-line indicator showing which slide presenterm is on.

---

## 12. Quick reference: presenterm flags & bindings used

| Used in plugin | Purpose |
|----------------|---------|
| `presenterm <file>` | Spawn presentation. |
| `<number>G` (presenterm binding) | Jump to slide N — drives the sync. |
| `kitty @ launch --type=os-window --copy-env presenterm <file>` | Spawn the window. |
| `kitty @ send-text --match id:<N> "<N>G"` | Inject keystrokes for sync. |
| `kitty @ close-window --match id:<N>` | Clean shutdown. |
| `~/.config/presenterm/config.yaml` `options.end_slide_shorthand`, `options.implicit_slide_ends` | Mirror counting rules. |
