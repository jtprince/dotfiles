
if [ -z "$HAVE_READ_JTP_PROFILE" ]; then
    source ~/.profile
fi

###############################################################################
# library files
###############################################################################

for config_file (~/.config/zsh/lib/*.zsh); do
  source $config_file
done



DISABLE_AUTO_TITLE="false"

function set_terminal_title() {
  echo -en "\e]2;$@\a"
}

source ~/.config/zsh/jtprince.zsh-theme


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
# Prompt
###############################################################################

# See jtprince.zsh-theme for more style

# If you have variables in your prompt, they will be substituted in each time
# its displayed. Consider single quotes to ensure the variable exists as a
# variable.
setopt prompt_subst

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

# RIGHT NOW WE HAVE THESE in _completion dir for quick startup

# kubectl
# [[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# helm
# [[ $commands[helm] ]] && source <(helm completion zsh)

# codefresh
# this is really slow, so until we figure out why, skip it
# [[ $commands[codefresh] ]] && source <(codefresh completion zsh)

###############################################################################
# Corrections
###############################################################################

# disable corrections on args
unsetopt correct_all
setopt correct
