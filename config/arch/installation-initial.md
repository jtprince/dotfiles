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
Additional packages -> See installation.yaml `core-packages`
Network Configuration -> Use Network Manager
Timezone -> America/Denver
Install
```

Then reboot (`shutdown now`, remove drive, reboot)

## Post-reboot

### Change to zsh

```bash
chsh
# -> /usr/zsh
```

Then logout and log back in.

### Set up wifi
```bash
 nmcli d wifi connect PrinceNest password <password>
```

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
yay -S python-ruyaml neovim-plug
```

### Reflector

```bash
yay -S reflector rsync
reflector --country US --fastest 10 --age 6 --save /etc/pacman.d/mirrorlist
```

### Launch sway

```
exec dbus-launch sway --exit-with-session
```

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
