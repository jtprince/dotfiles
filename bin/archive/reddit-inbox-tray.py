#!/usr/bin/env python
import signal
import sys
import time
from threading import Thread

import gi
import praw
import yaml

# these must come after import gi and before other imports
gi.require_version("Gtk", "3.0")
gi.require_version("AppIndicator3", "0.1")

from gi.repository import AppIndicator3  # noqa: E402
from gi.repository import GLib  # noqa: E402
from gi.repository import Gtk  # noqa: E402

username = sys.argv[1]

user_agent = "User-Agent: linux.reddit-inbox-tray:v0.0.1 (by /u/bwv549)"

REDDIT_ENV_PATH = "/home/jtprince/Dropbox/env/reddit"
# ICON_PATH = "
# ICON_PATH = "/home/jtprince/Dropbox/env/reddit/icons"
client_data = "dev_client.yml"
MESSAGES_ICON = "gtk3-demo"
NO_MESSAGES_ICON = "gtk-3-demo-symbolic.symbolic"

with open(f"{REDDIT_ENV_PATH}/{client_data}") as infile:
    client_data = yaml.load(infile)

with open(f"{REDDIT_ENV_PATH}/{username}.password") as infile:
    password = infile.read().rstrip()

login_credentials = dict(
    user_agent=user_agent, username=username, password=password, **client_data
)

reddit = praw.Reddit(**login_credentials)


class MessageIndicator:
    UPDATE_SECONDS = 5

    def __init__(self):
        self.app = "reddit-messages-tray"

        self.indicator = AppIndicator3.Indicator.new(
            self.app,
            icon_name="reddit messages",
            category=AppIndicator3.IndicatorCategory.OTHER,
        )
        self.indicator.set_status(AppIndicator3.IndicatorStatus.ACTIVE)

        have_unread_mail = self.have_unread_mail()
        icon = MESSAGES_ICON if have_unread_mail else NO_MESSAGES_ICON
        messages = "have messages" if have_unread_mail else "no messages"

        self.indicator.set_icon_full(icon, messages)

        # self.indicator.set_label("1 Monkey", self.app)
        # the thread:
        self.update = Thread(target=self.check_messages)
        # daemonize the thread to make the indicator stopable
        self.update.setDaemon(True)
        self.update.start()

    def create_menu(self):
        menu = Gtk.Menu()
        # menu item 1
        item_1 = Gtk.MenuItem(label="Menu item")
        # item_about.connect('activate', self.about)
        menu.append(item_1)
        # separator
        menu_sep = Gtk.SeparatorMenuItem()
        menu.append(menu_sep)
        # quit
        item_quit = Gtk.MenuItem(label="Quit")
        item_quit.connect("activate", self.stop)
        menu.append(item_quit)

        menu.show_all()
        return menu

    def have_unread_mail(self):
        _have_unread_mail = False
        for msg in reddit.inbox.unread(limit=1):
            _have_unread_mail = True

        print("have unread", _have_unread_mail)

        return _have_unread_mail

    def check_messages(self):
        while True:
            time.sleep(self.UPDATE_SECONDS)
            # apply the interface update using  GLib.idle_add()

            have_unread_mail = self.have_unread_mail()
            icon = MESSAGES_ICON if have_unread_mail else NO_MESSAGES_ICON
            messages = "have messages" if have_unread_mail else "no messages"
            print(icon)

            GLib.idle_add(
                self.indicator.set_icon_full,
                icon,
                messages,
                priority=GLib.PRIORITY_DEFAULT,
            )

    def stop(self, source):
        Gtk.main_quit()


MessageIndicator()
signal.signal(signal.SIGINT, signal.SIG_DFL)
Gtk.main()
