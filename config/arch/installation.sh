#!/bin/bash

# This is composed as a bash script, but I typically execute each line
# individually so that I can deal with any issues as they arise.

############################
# CORE
############################

# linux
pacman -S base base-devel linux linux-firmware  man-db man-pages texinfo --noconfirm

# networking and communication
pacman -S iwd wpa_supplicant gnome-keyring dhcpcd openssh wget httpie --noconfirm

# shell, permissions, git, and firmware support
# (udisks2 for uefi support in fwupdmgr)
pacman -S zsh git sudo vi vim neovim vim-plug git-delta-bin unzip p7zip udisks2 dmenu --noconfirm

# main terminals
pacman -S xterm alacritty --noconfirm

# those in wheel group can sudo with password
visudo # then uncomment wheel section

############################
# X11 core
############################

# get xorg display drivers and synaptics
pacman -S xorg-server xorg-apps xorg-xinit
pacman -S i3-wm i3lock --noconfirm

############################
# Sway core
############################

pacman -S sway swaylock
pacman -S xorg-server-xwayland

############################
# X11 details
############################

## install nvidia, ati, or intel specific drivers
# intel
pacman -S xf86-video-intel mesa --noconfirm
pacman -S xf86-video-nouveau --noconfirm
# <...>
# systemctl enable nvidia-persistenced  # if nvidia

# Add alacritty to /etc/bash.bashrc
# ...|Eterm|aterm|...
# ...|Eterm|alacritty|aterm|...

############################
# Graphical Interface
############################

# Make a user
useradd -m -g users -G wheel -s /bin/zsh jtprince
passwd jtprince

### JUMP to graphical interface

# install lightdm
pacman -S lightdm lightdm-gtk-greeter accountsservice --noconfirm ; systemctl enable lightdm

systemctl start lightdm
# then login to i3, start browser, sign-in your user, and get this file!

############################
# AUR helper
############################

## Install yay
git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si

############################
# Primary browser
############################

yay -S google-chrome --noconfirm
google-chrome-stable --user-data-dir=$HOME/.config/chrome-personal

############################
# MEGA
############################

# open browser, navigate here and download and install
# https://mega.nz/sync
sudo pacman -U Download/megasync-x86_64.pkg.tar.zst
# Login so it can start
# jtprince@gmail.com

############################
# Dropbox
############################

# install dropbox
yay -S dropbox dropbox-cli
# If you have gpg import errors, you'll probably need to do this:
curl https://linux.dropbox.com/fedora/rpm-public-key.asc
gpg --import rpm-public-key.asc

# reflector (for mirrorlists) NOTE: pause dropbox sync for this
yay -S reflector --noconfirm;  sudo reflector --country US --fastest 10 --age 6 --save /etc/pacman.d/mirrorlist

############################
# dotfiles
############################

# Password related utilities
chmod +x ~/MEGA/env/passwds_logins/INSTALL.sh
~/MEGA/env/passwds_logins/INSTALL.sh

git clone git@github.com:jtprince/dotfiles.git
cd ~ && ln -s ~/dotfiles/bin && rehash
dotfiles-configure --dry
dotfiles-configure

############################
# OTHER
############################

# Other sway/wayland stuff

yay -S wl-clipboard wl-clipboard-x11 wdisplays azote mako grimshot python-i3ipc
# pipewire screensharing stuff
yay -S pipewire xdg-desktop-portal xdg-desktop-portal-wlr
# chromium is on an older pipewire version, is this still needed?
# check https://wiki.archlinux.org/index.php/PipeWire
yay -S libpipewire02
# now go set the pipewire flag for chromium at this url (in both your settings)
chrome://flags/#enable-webrtc-pipewire-capturer

# ntpd
sudo pacman -S ntp --noconfirm; sudo systemctl enable ntpd.service

# install network manager
sudo pacman -S networkmanager network-manager-applet --noconfirm; sudo systemctl enable NetworkManager

# keychain
yay -S keychain docker-credential-secretservice-bin --noconfirm

# compositing manager
yay -S picom --noconfirm

# for python
yay -S pyenv pyenv-virtualenv python-pip ipython python-black python-pynvim python-poetry --noconfirm ; mkdir -p ~/virtualenvs

```
curl -sSL https://raw.githubusercontent.com/sdispater/poetry/master/get-poetry.py > get-poetry.py
python ./get-poetry.py
```

# handlr for mime-type management
yay -S handlr-bin

# ruby
# probably already installed
yay -S openssl readline zlib --noconfirm
yay -S ruby rbenv ruby-build --noconfirm
# pry likes readline
rbenv install --list
CONFIGURE_OPTS="--with-readline-dir=/usr/include/readline" rbenv install <SOME_VERSION>
# this is critical so that you can install gems with user and not root:
rbenv global <SOME_VERSION>

# notifications
# was using dunst, trying out xfce4-notifyd
yay -S xfce4-notifyd --noconfirm
# configure with xfce4-notifyd-config

# sound
yay -S pulseaudio pulseaudio-alsa pulseaudio-ctl --noconfirm
# sound tray
yay -S pasystray-git pavucontrol paprefs pavumeter --noconfirm

# bluetooth
yay -S bluez bluez-utils pulseaudio-bluetooth --noconfirm

# screen
yay -S arandr --noconfirm

# file manager and associated
yay -S pcmanfm gvfs gvfs-mtp udisks --noconfirm

# yay -S tree thunar thunar-media-tags-plugin thunar-archive-plugin thunar-shares-plugin thunar-volman tumbler ffmpegthumbnailer raw-thumbnailer libgsf thunar-dropbox gvfs gvfs-smb sshfs
# [now using pcmanfm, which comes with lxde]
yay -S tree --noconfirm

# cursor
yay -S xcursor-vanilla-dmz --noconfirm

# common file systems
yay -S ntfs-3g --noconfirm

# extraction and search
yay -S dtrx zip xclip ack --noconfirm

# install lxde (as a backup X desktop environment)
sudo pacman -S lxde --noconfirm

# configure your primary backlight output (typically acpi_video0 or intel_backlight)
# sudo sh -c 'echo "export BACKLIGHT=\"<GET THIS RIGHT>\"" > /etc/profile.d/backlight.sh'
# showing icons on all desktops for now

## Get good font rendering (looks like infinality)

sudo ln -s /etc/fonts/conf.avail/11-lcdfilter-default.conf /etc/fonts/conf.d
sudo ln -s /etc/fonts/conf.avail/10-sub-pixel-rgb.conf /etc/fonts/conf.d

# ensure that hinting-slight is already linked (should already be set)
ls -alh  /etc/fonts/conf.d/10-hinting-slight.conf  # should give /etc/fonts/conf.avail/10-hinting-slight.conf

# core fonts
yay -S ttf-dejavu ttf-roboto ttf-ubuntu-font-family --noconfirm

# standard fonts
yay -S noto-fonts noto-fonts-emoji noto-fonts-cjk ttf-ms-fonts ttf-tahoma ttf-liberation ttf-symbola --noconfirm

# programming font with ligatures
# yay -S otf-fira-code --noconfirm

# vim powerline
yay -S powerline-fonts-git --noconfirm

# font for status bar
yay -S ttf-font-icons --noconfirm

# font for fim (see FBFONT in profile)
yay -S terminus-font --noconfirm

# font with great icon support
yay -S otf-font-awesome --noconfirm

# a few others
yay -S otf-ipafont culmus cantarell-fonts --noconfirm

# link my own batch of fonts
ln -s ~/MEGA/env/appearance/fonts/dot-fonts ~/.local/share/fonts
fc-cache

# icons and themes
yay -S gnome-themes-standard  --noconfirm

# acpi # only for laptops
# yay -S acpi cbatticon  --noconfirm

# rg, ack, fd, fzf command (way better grep and needed for proximity-sort)
yay -S ripgrep ack fd fzf --noconfirm

# essential media players and control (xava is for fun visualizer)
yay -S youtube-music-bin playerctl xava --noconfirm

#############################
# AFTER RE-LOGIN
#############################

# install jira-cli
yay -S npm --noconfirm
npm install -g jira-cli
# to complete install, execute command from my README.md
cat ~/MEGA/env/cloud-and-apis/jira/jira-cli/README.md

pyenv install --list
# update these to latest patch version for each minor
pyenv install 3.7.10; pyenv install 3.8.9; pyenv install 3.9.4
pyenv global 3.9.4
# you need the neovim module in your current python shim for the nvim python
# plugin to work:
# If you see this error message:
# "This script requires vim7.0+ with Python 3.6 support", then you need to:
pip install neovim
# for pymarkdown
pip install PyMarkdown

gem install pry clipboard solargraph

# universal ctags
yay -S ctags --noconfirm

nvim -> :PlugInstall
# for reading settings file and other json stuff
:CocInstall coc-json
:CocInstall coc-python
:CocInstall coc-solargraph

# sad
yay -S sad fzf git-delta-bin

# locate
yay -S mlocate --noconfirm; sudo updatedb

# PDF readers
# zooming is restricted by page cache size, increase to get zoom into large docs
yay -S evince --noconfirm; gsettings set org.gnome.Evince page-cache-size 2014

# note: would install pdftk-bin here, but not working??
yay -S archey3 feh mplayer inkscape gimp eog geeqie gthumb youtube-dl pandoc-bin mp3splt audacity --noconfirm
# slack using system qt should avoid some wayland failures
yay -S slack-desktop zoom-system-qt --noconfirm
yay -S libreoffice libmythes mythes-en --noconfirm

# texlive fonts (needed for pandoc pdf conversion)
# texlive-latexextra needed for etoolbox.sty
yay -S texlive-core texlive-fontsextra texlive-latexextra --noconfirm
sudo ln -s /etc/fonts/conf.avail/09-texlive-fonts.conf /etc/fonts/conf.d/09-texlive-fonts.conf
sudo fc-cache && sudo mkfontscale && sudo mkfontdir && sudo rm -f fonts.dir fonts.scale

# ranger and deps
yay -S ranger atool highlight mediainfo odt2txt perl-image-exiftool transmission-cli w3m libcaca --noconfirm

# for password generation
yay -S words --noconfirm

# for numpy / scipy
yay -S gcc-fortran --noconfirm

yay -S gnome-system-monitor gnome-power-manager --noconfirm

# cheat sheets
yay -S cheat --noconfirm

# for personal python tray apps
# yay -S libappindicator-gtk3

# I haven't needed this for a while, so maybe see if really need it??
# haveged (generates system entropy to enable key signing)
# https://www.archlinux.org/news/gnupg-21-and-the-pacman-keyring/
# sudo bash
# ``` # can copy and paste in one chunk below
# pacman -S haveged --noconfirm
# systemctl start haveged
# systemctl enable haveged
# rm -fr /etc/pacman.d/gnupg
# pacman-key --init
# pacman-key --populate archlinux
# exit
# ```

# NEED TO FIGURE OUT THAT SYSTEMD stuff and do it!!

# find which package holds a particular file:
yay -S pkgfile --noconfirm ; sudo pkgfile --update

# for paccache
yay -S pacman-contrib --noconfirm

# connect android via usb (including usb-c)
yay -S jmtpfs --noconfirm
mkdir ~/mnt
# to mount phone once you've plugged it into usb:
# jmtpfs ~/mnt

# printing
yay -S cups cups-pdf --noconfirm
yay -S system-config-printer --noconfirm
# sudo systemctl enable cups.service
# sudo systemctl start cups.service
# sudo system-config-printer

# yay -S hplip --noconfirm

# system monitoring
yay -S libstatgrab pystatgrab gnome-system-monitor --noconfirm

# aws and google cli
yay -S aws-cli google-cloud-sdk --noconfirm

# docker
yay -S docker docker-compose --noconfirm
sudo gpasswd -a jtprince docker
sudo systemctl enable docker.service

# flashplugin
yay -S flashplugin pepper-flash --noconfirm

# torrents
yay -S deluge-gtk --noconfirm

# transfer files with android pixel
# yay -S simple-mtpfs --noconfirm
# simple-mtpfs -l
# mkdir ~/mnt
# simple-mtpfs --device 1 ~/mnt
# [will appear in thunar then]

# using tlp for battery optimizations
# follow instructions here: https://linrunner.de/tlp/installation/arch.html
# Should be roughly
yay -S tlp tlp-rdw
# then run this to know which other packages to install for the system
sudo tlp-stat -b
# e.g., `yay -S acpi_call`
sudo systemctl {start,enable} tlp.service
sudo systemctl enable NetworkManager-dispatcher.service
sudo systemctl mask systemd-rfkill.service
sudo systemctl mask systemd-rfkill.socket

# laptop mode tools
# yay -S laptop-mode-tools-git hdparm acpid --noconfirm
# sudo systemctl enable laptop-mode.service
# sudo systemctl enable acpid.service

# install secondary browser
yay -S firefox --noconfirm

# timezone update utility
yay -S tzupdate --noconfirm

# git and github
# diffr (better diff)
# yay -S diffr --noconfirm
# gh
yay -S github-cli --noconfirm

# informant (ensure arch news is read)
yay -S informant --noconfirm

#########################################
## kube
#########################################

yay -S kubectl kubectx --noconfirm
# then without the dry
kubernetes-setup-credentials --with-login --credentials --nicknames --dry

#########################################
## OPTIONAL
#########################################

Install the openconnect to connect to cisco vpn for 3plcentral
yay -S openconnect


# enable dnsmasq to shorten dns lookup
sudo pacman -S dnsmasq
sudo systemctl enable dnsmasq.service
sudo systemctl start dnsmasq.service
# then change uncomment and add this line to /etc/dnsmasq.conf
listen-address=::1,127.0.0.1

# wine (wine_gecko and wine-mono avoids reinstalls of those for each prefix)
yay -S wine-staging wine_gecko wine-mono
winecfg # --> go to staging tab and click Enable_CSMT for better graphic performance
# for gaming in wine (necessary fonts already installed)
yay -S lib32-alsa-lib lib32-alsa-plugins lib32-libpulse lib32-alsa-oss lib32-openal lib32-libxml2 lib32-mpg123 lib32-lcms2 lib32-giflib lib32-libpng lib32-gnutls lib32-virtualgl lib32-libldap

# drone (right now we are using 0.7.0 and later versions are busted)
# get the drone-cli PKGBUILD file and edit:
# pkgver=0.7.0
# sha256sums=('456b315245aacc9586622a8b3873c880c34f68c1f6d86c5e000abc3da411e28f')
# then makepkg and sudo pacman -U <pkg>.tar.xz

#########################################
## NOT REALLY USING
#########################################

# astah [optional]
yay -S astah-community jre
# then replace the last line of the file /usr/bin/astah with this:
export JAVA_HOME=/usr/lib/jvm/java-8-jre/jre
/usr/lib/jvm/java-8-jre/jre/bin/java $JAVA_OPTS -splash:"$ASTAH_HOME"/astah_splash_community.png -jar $CLASSPATH "$1" "$2" "$3" -nojvchk
