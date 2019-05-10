#!/bin/sh

xrandr \
    --output DP-3 --primary --mode 1920x1080 --pos 0x0 --rotate normal \
    --output HDMI1 --off \
    --output HDMI2 --off \
    --output DP1 --off \
    --output eDP-1 --off \
    --output VIRTUAL1 --off

randomise-bkg
xmodmap ~/.config/xmodmap
