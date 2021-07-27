#!/bin/bash

echo "================================================"
echo "systemctl --user status pipewire.socket pipewire"
echo "================================================"
systemctl --user status pipewire.socket pipewire


echo ""
echo "================================================"
echo "systemctl --user status pipewire-media-session"
echo "================================================"
systemctl --user status pipewire-media-session


echo ""
echo "================================================"
echo "systemctl --user status xdg-desktop-portal"
echo "================================================"
systemctl --user status xdg-desktop-portal
