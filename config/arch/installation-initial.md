# Installation

Basic instructions for a quick/clean install using archinstall.

## pre-archinstall

Need network connection:

```bash
iwctl device wlan0 show
# Should be `Powered on`
# If not, then:
rfkill unblock all

iwctl station wlan0 connect PrinceNest
<password>
```
```bash
archinstall
```

## archinstall

If you get a keyring issue [like this](https://github.com/archlinux/archinstall/issues/1389) when running archinstall, just [wait a minute](https://github.com/archlinux/archinstall/issues/1389#issuecomment-1235597526) and re-run the command and it should work.

Basic install using archinstall:

```script
Default is fine unless noted
Mirror region -> United States (space, then Enter)
Drive(s) -> [nvme0n1 typically]
Disk Layout -> "Wipe all ..." -> ext4; sep partition for home -> no
Encryption Password -> [set]
Hostname -> [set]
Root password -> [set]
User account -> password -> yes superuser -> 'Confirm and exit'
Profile -> desktop -> sway; graphics driver -> [whatever]
Audio -> pipewire
Kernels -> maybe linux-lts for now?
Additional packages -> See installation.yaml `core-packages` (??? trying nothing extra this time ??)
Network Configuration -> Use Network Manager
Timezone -> America/Denver
Install
```

Either install extra packages or log into root and install with pacman:

```bash
# sudo pacman -S ...
man-db        # documentation
man-pages     # documentation
sof-firmware  # if applicable
gnome-keyring
httpie
zsh
git
sudo
sheldon
p7zip
udisks2        # for uefi support in fwupdmgr
usbutils       # for lsusb etc
keychain
npm
vi
vim
fzf
ctags
xterm
rsync           # for reflector
alacritty
kitty
firefox
```

Then reboot (`shutdown now`, remove drive, reboot)

## Post-reboot

### Set up wifi
```bash
 nmcli d wifi connect PrinceNest password <password>
```

### Change to zsh and add to users group

sudo pacman -S zsh

```bash
chsh
# -> /bin/zsh
sudo gpasswd -a jtprince users

# TODO: change the group id!
```

Then logout and log back in.

#### Fallback

If nmcli isn't working can fallback to iwd
```bash
sudo systemctl start iwd dhcpcd
iwctl station wlan0 connect PrinceNest
```

### Install yay

```bash
 git clone https://aur.archlinux.org/yay.git
 cd yay && makepkg -si && cd $HOME
 ```

### Early yay dependencies

`ruyaml` is needed for `arch-installer.py` and better to install early before
`PIP_REQUIRE_VIRTUALENV` is activated. neovim-plug is useful for initial
neovim `PlugInstall`.

```bash
yay -S python-ruyaml neovim-plug ttf-dejavu-nerd noto-fonts
```

### Reflector

```bash
yay -S reflector
reflector --country US --fastest 10 --age 6 --save /etc/pacman.d/mirrorlist
```

### Launch sway

```
exec dbus-launch sway
```
Windows-Enter: terminal
Windows-Shift: Exit sway

## Get keys

* Open firefox and sign-in
* Navigate to `dropbox.com` -> `env/passwds_logins/`
* Click and download `dot-aws.secure.7z` and `dot-ssh.secure.7z`

```bash
# must be in home dir:
cd
7z x ~/Downloads/dot-ssh.secure.7z
7z x ~/Downloads/dot-aws.secure.7z
```

## Dotfiles

```bash
cd
git clone git@github.com:jtprince/dotfiles.git
cd
ln -s dotfiles/bin

# pick your resolution, 4k or hd
./bin/dotfiles-configure -r 4k
```

Then logout and log back in.

## neovim

Will need to give treesitter time to download all the language syntaxes.

```
nvim
:PlugInstall
:COQdeps
:CHADdeps
```
