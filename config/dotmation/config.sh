#!/bin/bash

ln -sf ~/dotfiles/config/dotmation ~/.config/
ln -sf ~/dotfiles/config/alias ~/.config/
ln -sf ~/dotfiles/config/xmodmap ~/.config/
ln -sf ~/dotfiles/config/git ~/.config/
ln -sf ~/dotfiles/config/gtk-3.0 ~/.config/
ln -sf ~/dotfiles/config/zsh ~/.config/
ln -sf ~/dotfiles/config/fontconfig ~/.config/
ln -sf ~/dotfiles/config/texlive ~/.config/
ln -sf ~/dotfiles/config/dunst ~/.config/
rm -rf ~/.config/i3
ln -sf ~/dotfiles/config/i3 ~/.config/
ln -sf ~/dotfiles/config/latex ~/.config/
ln -sf ~/dotfiles/config/conky ~/.config/
ln -sf ~/dotfiles/config/blockify ~/.config/
ln -sf ~/dotfiles/config/ranger ~/.config/
ln -sf ~/dotfiles/config/compton ~/.config/
ln -sf ~/dotfiles/config/isort.cfg ~/.config/
ln -sf ~/dotfiles/config/cheat ~/.config/
ln -sf ~/dotfiles/config/flake8 ~/.config/
ln -sf ~/dotfiles/config/ackrc ~/.config/
ln -sf ~/dotfiles/config/pylintrc ~/.config/

# all my gpg keys, currently just owlet key
ln -sf ~/MEGA/env/gpg/dot-gnupg .gnupg

# slack-term
ln -sf ~/MEGA/env/cloud-and-apis/slack-term ~/.config/slack-term

mkdir -p ~/npm
ln -sf ~/dotfiles/config/npmrc ~/.config

# create the actual git config file:
cat ~/dotfiles/config/git/config-public ~/MEGA/env/dotfiles-private/git/config > ~/.config/git/config

ln -sf ~/dotfiles/config/pulseaudio-ctl ~/.config/
ln -sf ~/dotfiles/config/nvim ~/.config/

# defaults for forked nvim in new term
ln -sf ~/dotfiles/config/Xdefaults-nvimgui ~/.config/


# xdg-open standard location
ln -sf ~/dotfiles/config/mimeapps.list ~/.config/

# remove any existing mimeapps.list and link in my own
mkdir -p ~/.local/share/applications/
rm -f ~/.local/share/applications/mimeapps.list
ln -sf ~/dotfiles/config/mimeapps.list ~/.local/share/applications/

ln -sf ~/dotfiles/config/docker ~/.docker
ln -sf ~/dotfiles/config/profile ~/.profile
ln -sf ~/dotfiles/config/xprofile ~/.xprofile

# .Xresource linking is handled in .profile file!
# but we do want to put the Xresources.d file into standard location
ln -sf ~/dotfiles/config/Xresources.d ~/.config/
ln -sf ~/dotfiles/config/gtkrc-2.0 ~/.gtkrc-2.0
ln -sf ~/dotfiles/config/pryrc ~/.pryrc
ln -sf ~/dotfiles/config/irbrc ~/.irbrc
ln -sf ~/dotfiles/config/gemrc ~/.gemrc

# Xdefaults is deprecated upstream, but make link til we don't need
ln -sf ~/dotfiles/config/Xresources ~/.Xdefaults
ln -sf ~/dotfiles/config/zsh/zshenv ~/.zshenv

#  ln 'okularpartrc', '.kde4/share/config/okularpartrc'

# if desired:
# cfg 'Xresources-local'

# if desired:
# cfg 'gtkrc-2.0-local'

ln -sf ~/dotfiles/bin ~/
