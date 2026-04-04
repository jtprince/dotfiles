# ls colors
autoload colors; colors;

# Enable ls colors
if [ "$DISABLE_LS_COLORS" != "true" ]
then
  # Find the option for using colors in ls, depending on the version: Linux or BSD
  if [[ "$(uname -s)" == "NetBSD" ]]; then
    # On NetBSD, test if "gls" (GNU ls) is installed (this one supports colors);
    # otherwise, leave ls as is, because NetBSD's ls doesn't support -G
    gls --color -d . &>/dev/null 2>&1 && alias ls='gls --color=tty'
  elif [[ "$(uname -s)" == "Darwin" ]]; then
    # macOS/BSD ls uses LSCOLORS
    export LSCOLORS="Gxfxcxdxbxegedabagacad"
    ls -G -d . &>/dev/null 2>&1 && alias ls='ls -G'
  else
    # GNU ls (Linux) uses LS_COLORS
    if [[ -f ~/.dir_colors ]]; then
      eval "$(dircolors -b ~/.dir_colors)"
    else
      eval "$(dircolors -b)"
    fi
    ls --color -d . &>/dev/null 2>&1 && alias ls='ls --color=auto'
  fi
fi

#setopt no_beep
setopt auto_cd
setopt multios
setopt cdablevarS

if [[ x$WINDOW != x ]]
then
    SCREEN_NO="%B$WINDOW%b "
else
    SCREEN_NO=""
fi

# Apply theming defaults
PS1="%n@%m:%~%# "

# git theming default: Variables for theming the git info prompt
ZSH_THEME_GIT_PROMPT_PREFIX="git:("         # Prefix at the very beginning of the prompt, before the branch name
ZSH_THEME_GIT_PROMPT_SUFFIX=")"             # At the very end of the prompt
ZSH_THEME_GIT_PROMPT_DIRTY="*"              # Text to display if the branch is dirty
ZSH_THEME_GIT_PROMPT_CLEAN=""               # Text to display if the branch is clean

# If you have variables in your prompt, they will be substituted in each time
# its displayed. Consider single quotes to ensure the variable exists as a
# variable.
setopt prompt_subst
