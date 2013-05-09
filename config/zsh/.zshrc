
##################################################################################################
# Environment
##################################################################################################

# xfce4-terminal currently has bug in Ubuntu preventing
# it from propogating the TERM variable properly.
# gnome-terminal will support 256 colors with this:
TERM="xterm-256color"

# Use emacs keybindings even if our EDITOR is set to vi
bindkey -e

# -U turns off any aliases you may have defined while function is loaded
# -z may be related to the KSH_AUTOLOAD variable but I don't know for sure
#autoload -Uz promptinit
#promptinit
##prompt adam1
#prompt bigfade

##################################################################################################
# oh my zsh
##################################################################################################

ZSH=$HOME/.config/oh-my-zsh

# good themes
# bira
# alanpeabody jtprince@prince ~/dev/mspire$                                    master ‹1.9.3-p385›
# export ZSH_THEME="bira"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git ruby)

source $ZSH/oh-my-zsh.sh

##################################################################################################
# Prompt
##################################################################################################

source ~/.config/zsh/jtprince.zsh-theme

##################################################################################################
# History
##################################################################################################

HISTSIZE=10000
SAVEHIST=10000
setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt HIST_IGNORE_SPACE
# not sure what this does
setopt HIST_NO_STORE
# When using a hist thing, make a newline show the change before executing it.
# Save the time and how long a command ran
# setopt EXTENDED_HISTORY
setopt HIST_VERIFY
setopt HIST_SAVE_NO_DUPS
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_FIND_NO_DUPS
HISTFILE=~/.cache/.zsh_history

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


##################################################################################################
# Aliases
##################################################################################################

source ~/.config/alias

# zsh specific aliases
alias zshrc='gvim ~/.config/zsh/.zshrc'

insert_sudo () { zle beginning-of-line; zle -U "sudo " }
zle -N insert-sudo insert_sudo
bindkey "^[s" insert-sudo

##################################################################################################
# Functions
##################################################################################################

function fix {
  x=$1
  y=${x#*:}
  gvim +${y%:} ${x%%:*}
}

function latexlive {
    if [ -e "$1" ]; then
        execute_on_modify.rb $1 tex_to_pdf.rb --no-delete-pdf -v {{}}
    else
        echo "latexlive <file>.tex"
    fi
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

function nautilusnd {
    local arg
    if [ $# -lt 1 ]
    then 
        arg=`pwd`
    else
        arg=$@
    fi
    nautilus --no-desktop -n $arg &
}

##################################################################################################
# File Associations
##################################################################################################

if [[ $DISPLAY = '' ]] then
    alias -s txt=vim
else
    alias -s txt=gvim
fi

if [[ -x `which libreoffice` ]]; then
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

if [[ -x `which inkview` ]]; then
    alias -s svg=inkview
fi

if [[ -x `which geeqie` ]]; then
    alias -s png=geeqie
fi

if [[ -x `which evince` ]]; then
    alias -s pdf='evince'
    alias -s ps='evince'
fi

##################################################################################################
# Directory navigation
##################################################################################################

# no 'cd dir' just 'dir'
setopt AUTO_CD

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

# 10 second wait if you do something that will delete everything.  I wish I'd had this before...
setopt RM_STAR_WAIT


