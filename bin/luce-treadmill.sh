#!/bin/sh
xrandr \
    --output DP1 --mode 1920x1080 --primary --pos 0x0 --rotate normal \
    --output HDMI1 --off \
    --output HDMI2 --off \
    --output eDP1 --off \

randomise-bkg
