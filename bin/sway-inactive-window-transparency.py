#!/usr/bin/python
"""

Script modified from:
https://github.com/swaywm/sway/blob/master/contrib/inactive-windows-transparency.py

Added ability to limit to certain specified applications.

yay -S python-i3ipc
AND/OR
pip install i3ipc
"""

import argparse
import signal
import sys
from functools import partial

import i3ipc

DEFAULT_UNFOCUSED_OPACITY = 0.60
DEFAULT_FOCUSED_OPACITY = 0.92


def set_opacity(container, opacity, args):
    # Todo simplify this logic
    if args.app_ids:
        if container.app_id in args.app_ids:
            container.command(f"opacity {opacity}")
    else:
        container.command(f"opacity {opacity}")


def on_window_focus(args, ipc, event):
    global prev_focused
    global prev_workspace

    focused = event.container
    workspace = ipc.get_tree().find_focused().workspace().num

    if (
        focused.id != prev_focused.id
    ):  # https://github.com/swaywm/sway/issues/2859
        set_opacity(focused, args.focused, args)
        # focused.command("opacity 1")
        if workspace == prev_workspace:
            set_opacity(prev_focused, args.unfocused, args)
        prev_focused = focused
        prev_workspace = workspace


def remove_opacity(ipc):
    for workspace in ipc.get_tree().workspaces():
        for w in workspace:
            set_opacity(w, 1, args)
    ipc.main_quit()
    sys.exit(0)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Sets transparency of unfocused windows."
    )
    parser.add_argument(
        "--focused",
        type=str,
        default=DEFAULT_FOCUSED_OPACITY,
        help="set opacity value in range 0...1",
    )

    parser.add_argument(
        "--unfocused",
        type=str,
        default=DEFAULT_UNFOCUSED_OPACITY,
        help="set opacity value in range 0...1",
    )
    parser.add_argument(
        "--app_ids",
        nargs="*",
        help="if defined, only for specified apps",
    )

    args = parser.parse_args()

    ipc = i3ipc.Connection()
    prev_focused = None
    prev_workspace = ipc.get_tree().find_focused().workspace().num

    for window in ipc.get_tree():
        if window.focused:
            prev_focused = window
        else:
            set_opacity(window, args.unfocused, args)
    for sig in [signal.SIGINT, signal.SIGTERM]:

        signal.signal(sig, lambda signal, frame: remove_opacity(ipc))
    ipc.on("window::focus", partial(on_window_focus, args))

    ipc.main()
