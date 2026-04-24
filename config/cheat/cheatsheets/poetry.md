
# recreate the lock file without upgrading
poetry lock --no-update

# ensure that you can view the github prompt on install or update
poetry install -vv
poetry update -vv

## Deal with poetry dbus secrets timeout in private repo
https://blog.frank-mich.com/python-poetry-1-0-0-private-repo-issue-fix/
Figure out where your python keyring directory should reside:
```
python -c "import keyring.util.platform_; print(keyring.util.platform_.config_root())"
```
# in your keyringrc.cfg file (probably ~/.config/python_keyring/keyringrc.cfg)
```
[backend]
default-keyring=keyring.backends.fail.Keyring
