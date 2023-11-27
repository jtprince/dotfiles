#!/bin/bash

COUNTRY="America"
CITY="Denver"

echo "Setting timezone to $COUNTRY/$CITY"
ln -sf /usr/share/zoneinfo/$COUNTRY/$CITY /etc/localtime

echo "Set the RTC from the system time"
hwclock --systohc

echo "Uncommenting en_US.UTF-8 in /etc/locale.gen"
# don't trust my bash escape skills to use the var without testing
sed -i 's/^#en_US.UTF-8/en_US.UTF-8/' /etc/locale.gen

echo "Running locale-gen"
locale-gen

echo "Using LANG=en_US.UTF-8 in /etc/locale.conf"

echo -n 'LANG=en_US.UTF-8' > /etc/locale.conf

echo "Allowing parallel downloads in /etc/pacman.conf"
sed -i 's/^#ParallelDownloads/ParallelDownloads/' /etc/pacman.conf
