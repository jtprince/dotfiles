#!/bin/sh

xrandr \
    --output eDP-1 --primary --mode 3840x2160 --pos 0x0 --rotate normal \
    --output DP-1 --off \
    --output DP-2 --off \
    --output DP-3 --off

randomise-bkg
