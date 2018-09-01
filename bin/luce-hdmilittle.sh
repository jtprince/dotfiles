#!/bin/sh
xrandr \
    --output HDMI1 --primary --mode 1680x1050 --pos 0x0 --rotate normal \
    --output HDMI2 --off \
    --output DP1 --off \
    --output eDP1 --off \
    --output VIRTUAL1 --off

randomise-bkg
xmodmap ~/.config/xmodmap
