
# dbus-send --session --dest=org.freedesktop.PowerManagement --type=method_call --print-reply --reply-timeout=2000 /org/freedesktop/PowerManagement org.freedesktop.PowerManagement.Shutdown

## TO shutdown with this script you need to do two things:
#% chmod u+s /sbin/shutdown  # this allows shutdown to be run as if you are superuser
#% add this to sudoers file (sudo visudo):
#  %admin ALL=(ALL) ALL, NOPASSWD: /sbin/shutdown  # the admin part is probably already there, you just need to add the NOPASSWD bit.
# on ubuntu, if you just want to kill everything without fully shutting down, run this command without the -P flag
# the -P flag tells the system to 'truly' power down.
sudo shutdown -P now
