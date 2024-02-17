Files in this dir go into: /etc/sudoers.d/

No big deal if this README ends up there as long there is a '.' in the
filename (these will be ignored by sudo).

Also, make sure that the files in that directory are 0400:

```bash
sudo mkdir -p /etc/sudoers.d
sudo cp /home/jtprince/dotfiles/config/sudoers.d/* /etc/sudoers.d/
sudo chmod 0400 /etc/sudoers.d/*
```
