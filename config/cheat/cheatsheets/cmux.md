---
tags: [ terminal, config ]
---

# cmux — Ghostty-based macOS multiplexer for AI coding agents.
# Config mimics my kitty setup. Settings split across TWO files:
#
#   ~/.config/cmux/cmux.json   app behavior + window/pane/tab keybinds  (dotfiles: config/cmux/)
#   ~/.config/ghostty/config   font, colors, cursor, scrollback, copy/paste  (dotfiles: config/ghostty/)
#
# cmux renders terminals with Ghostty, so appearance + terminal keys live in the ghostty file;
# cmux.json has NO font/color fields.

# ── CLI ─────────────────────────────────────────────────────────────

# print config file path
cmux config path

# validate cmux.json against schema (ground-truth check for binding names)
cmux config validate

# reload BOTH cmux.json and ghostty config live (no restart)
cmux reload-config

# open the Settings GUI
cmux settings open

# show default keyboard shortcuts / settings docs
cmux docs shortcuts
cmux docs settings

# send a notification from a script/agent (dock badge, pane ring)
cmux notify "message"

# ── Keybindings: cmux app  (owned by cmux.json) ─────────────────────
# Remapped to kitty muscle-memory. kitty "window"=cmux surface/pane; kitty "tab"=cmux workspace.
#
#   ctrl+shift+\        split right                 (kitty split)
#   ctrl+shift+-        split down
#   ctrl+shift+]        next surface                (kitty next_window)
#   ctrl+shift+[        prev surface                (kitty previous_window)
#   ctrl+shift+1..0     select surface N            (kitty first..tenth_window)
#   ctrl+shift+t        new surface                 (kitty new_tab)
#   ctrl+shift+w        close surface/pane          (kitty close_window)
#   ctrl+shift+q        close workspace             (kitty close_tab)
#   ctrl+shift+n        new window                  (kitty new_os_window)
#   ctrl+shift+→ / ←    next / prev workspace       (kitty next_tab / previous_tab, approx)
#   ctrl+shift+opt+t    rename workspace            (kitty set_tab_title)
#   ctrl+shift+return   zoom/unzoom split           (kitty toggle_maximized)
#   ctrl+shift+f11      toggle fullscreen
#   ctrl+shift+escape   reload config               (kitty load_config_file)
#
# Kept at cmux mac-native defaults (kitty had no equivalent):
#   cmd+opt+←→↑↓        focus pane directionally
#   cmd+shift+p         command palette
#   cmd+b               toggle sidebar
#   cmd+p               go to workspace (fuzzy)

# ── Keybindings: terminal  (owned by ghostty/config) ────────────────
#   ctrl+shift+c / v            copy / paste
#   ctrl+shift+pageup/pagedown  scroll page
#   ctrl+shift+home / end       scroll to top / bottom
#   ctrl+shift+= / -            font size +2 / -2
#   ctrl+shift+backspace        reset font size
#   ctrl+shift+delete           clear screen

# ── kitty features that DO NOT port ─────────────────────────────────
#   mega-hints.py (Rails/file -> gvim/tmux kitten), URL/path hint kittens,
#   unicode_input, live background-opacity keys (ctrl+shift+a>...),
#   external-pager scrollback (ctrl+shift+h). No cmux/Ghostty equivalent.

# ── Apply the dotfiles symlinks ─────────────────────────────────────
# ~/.config/cmux/cmux.json exists as a real file (cmux auto-creates it); back it up first
# so dotfiles-configure can symlink the dir cleanly:
mv ~/.config/cmux ~/.config/cmux.bak
dotfiles-configure --dry     # preview
dotfiles-configure           # apply (symlinks config/cmux and config/ghostty into ~/.config)
