#!/bin/sh
xrandr \
    --output edP-1 --primary --mode 3840x2160 --pos 0x0 --rotate normal
    --output HDMI2 --off \
    --output HDMI1 --off \
    --output DP1 --off \
    --output VIRTUAL1 --off

randomise-bkg
