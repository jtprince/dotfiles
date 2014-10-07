#!/bin/sh
xrandr --output HDMI-0 --mode 1920x1080 --pos 2880x0 --rotate normal --output DP-4 --off --output DP-3 --off --output DP-2 --mode 2880x1800 --pos 0x0 --rotate normal --output DP-1 --off --output DP-0 --off
nvidia-settings -a CurrentMetaMode="DFP-3:2880x1800+0+0, DFP-2: 1920x1080+2880+0 { ViewPortOut=1820x1022+50+29 }"
