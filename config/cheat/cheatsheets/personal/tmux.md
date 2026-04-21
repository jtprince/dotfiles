**tmux auto-attach setup (your case)**
- New SSH shell → attaches to `default` session if exists
- Otherwise → creates `default`

*Core prefix*
- `Ctrl-b` (default)

*Session management*
- List sessions: `tmux ls`
- Attach: `tmux attach -t default`
- Detach: `Ctrl-b d`
- Kill session: `tmux kill-session -t default`

*Windows*
- New window: `Ctrl-b c`
- Next/prev: `Ctrl-b n` / `Ctrl-b p`
- List: `Ctrl-b w`
- Rename: `Ctrl-b ,`
- Close: `exit` or `Ctrl-b &`

*Panes*
- Split horiz: `Ctrl-b "`
- Split vert: `Ctrl-b %`
- Navigate: `Ctrl-b arrow`
- Resize: `Ctrl-b Ctrl-arrow`
- Close: `exit`

*Common fixes*
- Stuck/nested tmux: `echo $TMUX` (non-empty = inside)
- Force new session: `tmux new -s other`
- Reattach if dropped SSH: just reconnect (auto-attach runs)
