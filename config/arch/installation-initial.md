# Installation

Basic instructions for a quick/clean install using the arch install guide.

## Network connection

```bash
iwctl device wlan0 show
# Should be `Powered on`
# If not, then:
rfkill unblock all

iwctl station wlan0 connect PrinceTPLink
<password> # <--this is the next line
```

## arch install

See the [arch installation guide](https://wiki.archlinux.org/title/installation_guide) for details.

```bash
# Older disks
export DISKDEV="/dev/sda"
export BOOTDEV="${DISKDEV}1"
export ROOTDEV="${DISKDEV}2"
# Newer disks
export DISKDEV="/dev/nvme0n1"
export BOOTDEV="${DISKDEV}p1"
export ROOTDEV="${DISKDEV}p2"
```

### Format partitions

(An EFI partition /boot and root, ext4). Add swapfile later.
* `cgdisk /dev/sda2`
    * EFI: ef00
    * Linux LUKS: 8309

### Encrypt, format, and mount
```bash
cryptsetup -y -v luksFormat $ROOTDEV
cryptsetup open $ROOTDEV root
mkfs.ext4 /dev/mapper/root
mount /dev/mapper/root /mnt
mkfs.fat -F32 $BOOTDEV
mount --mkdir $BOOTDEV /mnt/boot
```
### Install base packages

```bash
# before pacstrap
reflector --country US --fastest 10 --age 6 --save /etc/pacman.d/mirrorlist

pacstrap -K /mnt base linux linux-firmware base-devel networkmanager vim zsh intel-ucode wget
genfstab -U /mnt >> /mnt/etc/fstab
arch-chroot /mnt
```

### Basic Setup

```bash
export MYARCHBASE="https://raw.githubusercontent.com/jtprince/dotfiles/main/config/arch"
curl -O "$MYARCHBASE/scripts/setup.sh"
bash setup.sh

# edit mkinitcpio
vim /etc/mkinitcpio.conf
# Put `encrypt` between block and filesystems
# HOOKS=(base udev autodetect modconf kms keyboard keymap consolefont block encrypt filesystems fsck)
mkinitcpio -P

passwd

bootctl install

cd /boot/loader
curl -O "$MYARCHBASE/files/boot/loader.conf"
cd /boot/loader/entries
curl -O "$MYARCHBASE/files/boot/arch.conf"

# Now, follow instructions in the arch file to get the uuid in there
vim /boot/loader/entries/arch.conf

exit
umount -R /mnt
sudo shutdown now
```

Then reboot (`shutdown now`, remove drive, reboot)

## Post-reboot

### Set up wifi
```bash
systemctl start NetworkManager
nmcli d wifi connect PrinceTPLink password <password>
```

## install some initial packages

```bash
# pacman -S ...
man-db        # documentation
man-pages     # documentation
sof-firmware  # if applicable
gnome-keyring
httpie
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

## Make a swap file

```bash
dd if=/dev/zero of=/swapfile bs=1M count=8k status=progress
chmod 0600 /swapfile
mkswap -U clear /swapfile
swapon /swapfile
echo "/swapfile none swap defaults 0 0" >> /etc/fstab
```

### Add users and groups with specific ids

```bash
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
neovim `PlugInstall`. github-cli lets us start with dotfiles and edit it if
needed.

```bash
yay -S python-ruyaml ttf-dejavu-nerd noto-fonts github-cli neovim
```
### Launch sway

```bash
sway
```

Windows-Enter: open terminal
Windows-Shift-Q: close window
Windows-Shift-E: exit sway

## Dotfiles

```bash
cd
gh auth login
gh repo clone jtprince/dotfiles
ln -s dotfiles/bin
# pick your resolution, 4k or hd
./bin/dotfiles-configure -r 4k
```

Then logout and log back in.

## neovim

Will need to give treesitter time to download all the language syntaxes.

```
nvim-switcher current
nvim
(lazy will load everything)
```

## Setup keys

Setup .ssh and .aws keys after installing Dropbox; see:
`~/Dropbox/env/passwds_logins/INSTALL.sh`
