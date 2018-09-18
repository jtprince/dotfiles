#!/usr/bin/env python3
import signal
import sys
import time
from threading import Thread

import praw
import gi
# these must come after import gi and before other imports
gi.require_version('Gtk', '3.0')
gi.require_version('AppIndicator3', '0.1')

from gi.repository import AppIndicator3  # noqa: E402
from gi.repository import GLib  # noqa: E402
from gi.repository import Gtk  # noqa: E402

username = sys.argv[1]

user_agent = ("APP for checking my reddit inbox")
reddit = praw.Reddit(user_agent = user_agent)

with open(f"/home/jtprince/Dropbox/env/reddit/{username}.password") as infile:
    password = infile.read()

reddit.login(username = 'bwv549', password = password)

mail = "false"

for msg in reddit.get_unread(limit=1):
    print(msg)
    mail = "true"

exit(1)


class Indicator():
    def __init__(self):
        self.app = 'test123'
        iconpath = '/usr/share/icons/Adwaita/16x16/status/'

        self.indicator = AppIndicator3.Indicator.new_with_path(
            self.app,
            icon_name='reddit messages',
            icon_theme_path=iconpath,
            category=AppIndicator3.IndicatorCategory.OTHER
        )
        self.indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)
        self.indicator.set_menu(self.create_menu())
        iconpath = '/usr/share/icons/Adwaita/16x16/status'
        icon_name = "/usr/share/icons/Adwaita/16x16/status/appointment-soon.png"
        icon_name = "appointment-soon"
        self.indicator.set_icon_full(icon_name, "no messages")
        # self.indicator.set_label("1 Monkey", self.app)
        # the thread:
        self.update = Thread(target=self.show_seconds)
        # daemonize the thread to make the indicator stopable
        self.update.setDaemon(True)
        self.update.start()

    def create_menu(self):
        menu = Gtk.Menu()
        # menu item 1
        item_1 = Gtk.MenuItem(label='Menu item')
        # item_about.connect('activate', self.about)
        menu.append(item_1)
        # separator
        menu_sep = Gtk.SeparatorMenuItem()
        menu.append(menu_sep)
        # quit
        item_quit = Gtk.MenuItem(label='Quit')
        item_quit.connect('activate', self.stop)
        menu.append(item_quit)

        menu.show_all()
        return menu

    def show_seconds(self):
        t = 2
        while True:
            time.sleep(1)
            # apply the interface update using  GLib.idle_add()
            GLib.idle_add(
                self.indicator.set_icon_full,
                "changes-prevent", "message",
                priority=GLib.PRIORITY_DEFAULT
                )
            t += 1

    def stop(self, source):
        Gtk.main_quit()


Indicator()
signal.signal(signal.SIGINT, signal.SIG_DFL)
Gtk.main()
