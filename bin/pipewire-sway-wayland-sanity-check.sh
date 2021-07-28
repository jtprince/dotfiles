#!/bin/bash

echo "================================================"
echo "libpipewire02 installed?"
echo "================================================"
yay -Ss libpipewire02 | grep Installed

echo ""
echo "================================================"
echo "check that your browser has this enabled!!!"
echo "================================================"
echo "chrome://flags/#enable-webrtc-pipewire-capturer"

echo ""
echo "================================================"
echo "systemctl --user status pipewire.socket pipewire"
echo "================================================"
systemctl --user status pipewire.socket pipewire

echo "#############################################################"
echo "The following may be inactive and desktop sharing still work"
echo "But might activate window sharing??"
echo "#############################################################"
echo "#############################################################"
echo "#############################################################"
echo "#############################################################"
echo "#############################################################"

echo ""
echo "================================================"
echo "systemctl --user status pipewire-media-session"
echo "================================================"
systemctl --user status pipewire-media-session
# systemctl --user stop pipewire-media-session
# sleep 1
# systemctl --user start pipewire-media-session
# systemctl --user status pipewire-media-session


echo ""
echo "================================================"
echo "systemctl --user status xdg-desktop-portal"
echo "================================================"
systemctl --user status xdg-desktop-portal
# systemctl --user stop xdg-desktop-portal
# sleep 1
# systemctl --user start xdg-desktop-portal
# systemctl --user start xdg-desktop-portal


