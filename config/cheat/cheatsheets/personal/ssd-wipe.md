For an nvme system

Launch a USB (either Ubuntu or Manjaro Gnome??)

# manjaro
# (login to wifi)
sudo pacman -Syu
sudo pacman -S nvme-cli

# Find your main partition
lsblk

# reformat the disk securely
sudo nvme format /dev/nvme0n1 -s 1 -f 
    # -> Looking for `Success formatting namespace:1`

# To verify
sudo fdisk -l /dev/nvme0n1
