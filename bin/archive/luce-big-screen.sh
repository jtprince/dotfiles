#!/bin/sh
xrandr --output HDMI2 --mode 1920x1080 --pos 1920x0 --rotate normal --output HDMI1 --primary --mode 1920x1080 --pos 0x48 --rotate normal --output DP1 --off --output eDP1 --off --output VIRTUAL1 --off
overscan-correct
randomise-bkg
xmodmap ~/.config/xmodmap
