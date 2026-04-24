# Cron is a PITA for various reasons:
#
# 1. You have to have a mail server to capture stdout/stderr and if the output
#    is over some small amount, it will typically fail.
# 2. Cron starts with a blank slate environment, so many things you take for
#    granted (like a command like "cat") are not available, unless/until you
#    alter the path or fully qualify those commands (but then subprocesses don't
#    necessarily have access to the path so they will fail unless all those
#    commands were fully qualified, also).
# 3. The default shell for cron (on ubuntu at least) is not bash but the bourne
#    shell, which sucks.
# 4. It is annoying to debug since you have to wait, at a minimum, for the next
#    minute to test.
# 5. Times are relative to your server time, and different servers use difft
#    timezones.
#
# If you're using python, it's also a PITA because you take for granted that
# something like pyenv will just work, but it will not.

# Determine the timezone of your server (use date or see localtime symlink)
date
date +"%Z %z" # name and offset
ls -alh /etc/localtime

# On ubuntu with user jtprince using cron-apt for mail delivery
cat /var/mail/jtprince

# On ubuntu, see cron logs
sudo cat /var/log/syslog

# Or, see without sudo using journalctl (-q to quiet warning since not admin)
journalctl -q -u cron

# Edit and immediately install your edits:
crontab -e

# List your crontab
crontab -l

# Show the crontab for a particular user (i.e., as root):
crontab -u jtprince -l

# Every minute (good for testing):
* * * * * <blah>

# Once a day at 1:30 PM:
30 13 * * * <blah>

# Use bash instead of sh and set up PATH (just add lines to top of crontab)
SHELL=/bin/bash
PATH=/usr/bin:/bin:/usr/local/bin
16 21 * * * cd src/xtomap && ./scripts/run-eastern-update.sh

# pyenv
# I would love to do this on crontab line, but does not seem to work
# instead, make a wrapper script for whatever you want to run

---
#!/bin/bash

# export PATH="$HOME/.pyenv/bin:$PATH"
# eval "$(pyenv init --path)"
# eval "$(pyenv virtualenv-init -)"

# Add other env vars
export XTO_CONFIG_DIR="$HOME/xtoconfig"

# cron stdio goes to mail (if configured), so better to capture logs local
python scripts/run-eastern-update.py >> run.log
