```bash
diskutil list
# usb is usually last, probably /dev/disk4

diskutil unmountDisk /dev/disk4

# warning: check that there aren't any other manjaro iso's in Downloads
# or make this more specific

sudo dd if="$HOME/Downloads/manjaro-gnome*.iso" of=/dev/rdisk4 bs=4m status=progress

sync

diskutil eject /dev/disk4
```
