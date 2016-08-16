#!/bin/sh
xrandr --output HDMI1 --mode 1920x1080 --primary --pos 0x0 --rotate normal --output DP1 --off --output eDP1 --off --output VGA1 --off
overscan-correct
randomise-bkg
