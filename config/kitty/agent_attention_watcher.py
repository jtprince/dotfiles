"""Kitty watcher: persistent per-window attention highlight for AI agents.

Set:   `kitty-agent-attention` (bin/) sets the `agent_attention` user var.
Clear: focusing the window (on_focus_change unsets the var), typing a new
       command into it (on_cmd_startstop unsets the var), or manually via
       `kitty-agent-clear` (bin/).

on_set_user_var is the single place that paints/restores the background, so
every clear path (agent hook, focus, command-start, manual clear) goes
through one code path. It also self-clears immediately if the window is
already focused at the moment the alert is requested — on_focus_change only
fires on a focus *transition*, so a window that was already focused when the
agent finished would otherwise never get an edge to clear on.

NORMAL_BG/NORMAL_FG mirror kitty.common.conf's `background`/`foreground` —
keep them in sync if the theme changes.
"""
from typing import Any

VAR = 'agent_attention'
ALERT_BG = '#5a0000'
NORMAL_BG = '#000000'
NORMAL_FG = '#dddddd'


def _clear(boss: Any, window: Any) -> None:
    boss.call_remote_control(window, ('set-user-vars', f'--match=id:{window.id}', VAR))


def on_set_user_var(boss: Any, window: Any, data: dict) -> None:
    waiting = window.user_vars.get(VAR) == '1'
    if waiting and window.is_focused:
        _clear(boss, window)
        return
    colors = [f'background={ALERT_BG}'] if waiting else [f'background={NORMAL_BG}', f'foreground={NORMAL_FG}']
    boss.call_remote_control(window, ('set-colors', f'--match=id:{window.id}', *colors))


def on_focus_change(boss: Any, window: Any, data: dict) -> None:
    if data.get('focused') and window.user_vars.get(VAR) == '1':
        _clear(boss, window)


def on_cmd_startstop(boss: Any, window: Any, data: dict) -> None:
    if data.get('is_start') and window.user_vars.get(VAR) == '1':
        _clear(boss, window)
