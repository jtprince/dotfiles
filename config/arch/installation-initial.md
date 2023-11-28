# Installation

Basic instructions for a quick/clean install using the arch install guide.

## Network connection

```bash
iwctl device wlan0 show
# Should be `Powered on`
# If not, then:
rfkill unblock all

iwctl station wlan0 connect PrinceNest
<password>
```

## arch install

Follow the [arch installation
guide](https://wiki.archlinux.org/title/installation_guide), typically:

1. Two partitions (an EFI partition /boot and root, ext4). Add swapfile later.
    * `cgdisk /dev/sda2`
        * EFI: ef00
        * Linux LUKS: 8309
2. Encrypting an entire system -> LUKS on a partition

```
# before pacstrap
reflector --country US --fastest 10 --age 6 --save /etc/pacman.d/mirrorlist

pacstrap -K /mnt base linux linux-firmware base-devel networkmanager vim zsh intel-ucode
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt

curl -O https://github.com/jtprince/dotfiles/config/arch/scripts/time_and_lang.sh
bash time_and_lang.sh
```

Then reboot (`shutdown now`, remove drive, reboot)

## Post-reboot

### Set up wifi
```bash
nmcli d wifi connect PrinceNest password <password>
```

If nmcli isn't working can fallback to iwd
```bash
sudo systemctl start iwd dhcpcd
iwctl station wlan0 connect PrinceNest
```



## install some initial packages

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
unzip
udisks2        # for uefi support in fwupdmgr
usbutils       # for lsusb etc
keychain
npm
vi
vim
neovim-nvim-treesitter
fzf
ctags
xterm
rsync           # for reflector
alacritty
kitty
foot  # default sway terminal
firefox
sway
```

### Add users and groups with specific ids

```
groupmod -g 1221 users
useradd -m -u 1000 -g users -G wheel -s /bin/zsh jtprince
passwd jtprince
chfn -f "John T. Prince" jtprince

visudo
# Uncomment the line %wheel ALL=(ALL:ALL) ALL
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
### Launch sway

```
sway
```

Windows-Enter: open terminal
Windows-Shift-Q: close window
Windows-Shift-E: exit sway

Exit sway

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
