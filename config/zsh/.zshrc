
if [ -z "$HAVE_READ_JTP_PROFILE" ]; then
    source ~/.profile
fi

function cmd_exists {
    command -v "$1" >/dev/null 2>&1
}

###############################################################################
# Environment
###############################################################################

# xfce4-terminal currently has bug in Ubuntu preventing
# it from propogating the TERM variable properly.
# gnome-terminal will support 256 colors with this:

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

###############################################################################
# oh my zsh
###############################################################################

#ZSH=$HOME/.config/oh-my-zsh

# plugins in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# plugins=(poetry git ruby rake python poetry)

#DISABLE_AUTO_UPDATE="true"
#source $ZSH/oh-my-zsh.sh

###############################################################################
# Prompt
###############################################################################

for config_file (~/.config/zsh/lib/*.zsh); do
  source $config_file
done

source ~/.config/zsh/jtprince.zsh-theme

# Use modern completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' menu select=2
eval "$(dircolors -b)"
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true

zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# by default: export WORDCHARS='*?_-.[]~=/&;!#$%^(){}<>'
# we take out the slash, period, angle brackets, dash here.
export WORDCHARS='*?_[]~=&;!#$%^(){}'

[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"    history-beginning-search-backward
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}"  history-beginning-search-forward


###############################################################################
# Zsh or more complex Aliases (simple aliases go in .profile)
###############################################################################

source ~/.config/alias

alias zedit="gvim ~/.config/zsh/.zshrc"
alias zsource=". ~/.config/zsh/.zshrc && echo 'ZSH config sourced"

insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "^[s" insert-sudo

export NUM_CPU_CORES=`grep -c ^processor /proc/cpuinfo`
alias bundlei="bundle install --jobs=$NUM_CPU_CORES"

###############################################################################
# Functions
###############################################################################

function include () {
    [[ -f "$1" ]] && source "$1"
}

function ooffice {
    libreoffice --minimized --nologo "$@" &
}

function oowriter {
    # if they gave an argument but it didn't exist as a filename
    if [ $# -ne 0 ] && [ ! -f "$1" ]
    then
        # if the document doesn't exist, copy a temple file to it
        cp $HOME/Dropbox/Templates/one-inch-margins.odt $1
    fi
    libreoffice --minimized --nologo --writer "$@" &
}

###############################################################################
# Permissions
###############################################################################

alias dirs_fix_permissions_jtp="find . -type d -exec chmod 0755 {} \;"

###############################################################################
# File Associations
###############################################################################

if [[ $DISPLAY = '' ]] then
    alias -s txt=vim
else
    alias -s txt=gvim
fi

if cmd_exists libreoffice ; then
    WORDPROCESSOR='libreoffice --writer --minimized --nologo'
    SPREADSHEET='libreoffice --calc --minimized --nologo'
    PRESENTATION='libreoffice --impress --minimized --nologo'

    alias -s doc=$WORDPROCESSOR
    alias -s odt=$WORDPROCESSOR

    alias -s xls=$SPREADSHEET
    alias -s xlsx=$SPREADSHEET
    alias -s ods=$SPREADSHEET

    alias -s odp=$PRESENTATION
    alias -s ppt=$PRESENTATION
fi

if cmd_exists inkview ; then
    alias -s svg=inkview
fi

if cmd_exists geeqie ; then
    alias -s png=geeqie
fi

if cmd_exists evince ; then
    alias -s pdf='evince'
    alias -s ps='evince'
fi

###############################################################################
# Directory navigation
###############################################################################

# no 'cd dir' just 'dir'
# setopt AUTO_CD

# Now we can pipe to multiple outputs!
setopt MULTIOS

# This makes cd=pushd
setopt AUTO_PUSHD

# No more annoying pushd messages...
# setopt PUSHD_SILENT

# blank pushd goes to home
setopt PUSHD_TO_HOME

# this will ignore multiple directories for the stack.  Useful?  I dunno.
setopt PUSHD_IGNORE_DUPS

# 10 second wait if you do something that will delete everything.
setopt RM_STAR_WAIT

if [[ $TERM == xterm-termite ]]; then
  . /etc/profile.d/vte.sh
  __vte_osc7
fi

###############################################################################
# other
###############################################################################

# not sure why this won't work in my profile...
if cmd_exists virtualenvwrapper.sh ; then
    source `which virtualenvwrapper.sh`
fi

###############################################################################
# ssh agent with envoy
###############################################################################
# % sudo pacman -S envoy
# % systemctl enable envoy@ssh-agent.socket
if cmd_exists envoy ; then
    envoy -t ssh-agent
    source <(envoy -p)
fi

###############################################################################
# autocomplete
###############################################################################

# kubectl
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# helm
[[ $commands[helm] ]] && source <(helm completion zsh)
