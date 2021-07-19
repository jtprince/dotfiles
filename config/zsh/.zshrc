
if [ -z "$HAVE_READ_JTP_PROFILE" ]; then
    source ~/.profile
fi

###############################################################################
# library and theme files
###############################################################################

for config_file (~/.config/zsh/lib/*.zsh); do
  source $config_file
done

source ~/.config/zsh/jtprince.zsh-theme

###############################################################################
# Shell aliases
###############################################################################
#
# simple aliases that would apply to bash, too:
# (zsh specific aliases go in lib aliases.zsh)
source ~/.config/alias

# See completion dir for autocomplete

###############################################################################
# Plugins with sheldon
###############################################################################

eval "$(sheldon source)"
