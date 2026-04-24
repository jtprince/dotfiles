
## To see what is actually started:
loginctl session-status

If you see something like:
    discover_other_daemon: 1
then a daemon is already running somehow or somewhere

## What env vars are you using?

cat ~/.config/sway/env
# also, your startup script:
cat ~/bin/start

## How is sway configured to be launched?
cat /etc/sway/config.d/50-systemd-user.conf

## Are you using a user gnome-keyring-daemon?
systemctl status --user gnome-keyring-daemon

## Trying to deal with poetry dbus secrets timeout in private repo
https://blog.frank-mich.com/python-poetry-1-0-0-private-repo-issue-fix/
Figure out where your python keyring directory should reside:
```
python -c "import keyring.util.platform_; print(keyring.util.platform_.config_root())"
```
# in your keyringrc.cfg file (probably ~/.config/python_keyring/keyringrc.cfg)
```
[backend]
default-keyring=keyring.backends.fail.Keyring
```
