#!/bin/sh

xrandr \
    --output HDMI1 --mode 1920x1080 --pos 2560x0 --rotate normal \
    --output eDP1 --mode 2560x1440 --pos 0x0 --rotate normal \
    --output HDMI2 --off \
    --output DP1 --off \
    --output VIRTUAL1 --off

overscan-correct
