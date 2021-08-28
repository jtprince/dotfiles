#!/usr/bin/env bash

#
# Enable root access to x-windows system.
#
# Motivation: Trying to run a graphical application as root via su, sudo in a 
# Wayland session (e.g. GParted or Gedit), will fail. Apps which use polkit to
# request administrator permissions for just certain operations and only when 
# needed are not affected (they are not started as root right away). 
# [1] https://bugzilla.redhat.com/show_bug.cgi?id=1274451
#
# Based on a Reddit comment.
# [2] https://www.reddit.com/r/Fedora/comments/5eb633/solution_running_graphical_app_with_sudo_in/

if (( $# != 1 )); then
	echo "Illegal number of parameters."
	echo
	echo "Usage: wsudo [command]"
	exit 1
fi

for cmd in sudo xhost; do
	if ! type -P $cmd &>/dev/null; then
		echo "$cmd it's not installed. Aborting." >&2
		exit 1
	fi
done

xhost +SI:localuser:root
sudo $1
#disable root access after application terminates
xhost -SI:localuser:root
#print access status to allow verification that root access was removed
xhost