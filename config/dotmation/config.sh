
ln -s ~/dotfiles/config/dotmation ~/.config/
ln -s ~/dotfiles/config/alias ~/.config/
ln -s ~/dotfiles/config/xmodmap ~/.config/
ln -s ~/dotfiles/config/git ~/.config/
ln -s ~/dotfiles/config/gtk-3.0 ~/.config/
ln -s ~/dotfiles/config/zsh ~/.config/
ln -s ~/dotfiles/config/fontconfig ~/.config/
ln -s ~/dotfiles/config/texlive ~/.config/
ln -s ~/dotfiles/config/dunst ~/.config/
ln -s ~/dotfiles/config/i3 ~/.config/
ln -s ~/dotfiles/config/latex ~/.config/
ln -s ~/dotfiles/config/conky ~/.config/
ln -s ~/dotfiles/config/blockify ~/.config/
ln -s ~/dotfiles/config/ranger ~/.config/
ln -s ~/dotfiles/config/compton ~/.config/
ln -s ~/dotfiles/config/isort.cfg ~/.config/

mkdir ~/npm
ln -s ~/dotfiles/config/npmrc ~/.config
 
# create the actual git config file:
cat ~/dotfiles/config/git/config-public ~/Dropbox/env/dotfiles-private/git/config > ~/.config/git/config

ln -s ~/dotfiles/config/pulseaudio-ctl ~/.config/
ln -s ~/dotfiles/config/nvim ~/.config/

# defaults for forked nvim in new term
ln -s ~/dotfiles/config/Xdefaults-nvimgui ~/.config/


# xdg-open standard location
ln -s ~/dotfiles/config/mimeapps.list ~/.config/

# remove any existing mimeapps.list and link in my own
mkdir -p ~/.local/share/applications/
rm -f ~/.local/share/applications/mimeapps.list
ln -s ~/dotfiles/config/mimeapps.list ~/.local/share/applications/

ln -s ~/dotfiles/config/profile ~/.profile
ln -s ~/dotfiles/config/xprofile ~/.xprofile
# .Xresource linking is handled in .profile file!
# but we do want to put the Xresources.d file into standard location
ln -s ~/dotfiles/config/Xresources.d ~/.config/
ln -s ~/dotfiles/config/gtkrc-2.0 ~/.gtkrc-2.0
ln -s ~/dotfiles/config/pryrc ~/.pryrc
ln -s ~/dotfiles/config/irbrc ~/.irbrc
ln -s ~/dotfiles/config/gemrc ~/.gemrc

# Xdefaults is deprecated upstream, but make link til we don't need
ln -s ~/dotfiles/config/Xresources ~/.Xdefaults
ln -s ~/dotfiles/config/zsh/zshenv ~/.zshenv



#  ln 'okularpartrc', '.kde4/share/config/okularpartrc'

  # if desired:
  # cfg 'Xresources-local'

  # if desired:
  # cfg 'gtkrc-2.0-local'
end

ln -s ~/dotfiles/bin ~/
