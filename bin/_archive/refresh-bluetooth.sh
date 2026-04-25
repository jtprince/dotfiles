#!/bin/bash

echo -e "power off\n" | bluetoothctl
sleep 1

sudo systemctl restart bluetooth.service

echo -e "connect 08:DF:1F:44:3E:C6\n" | bluetoothctl
sleep 1

echo -e "power on\n" | bluetoothctl
