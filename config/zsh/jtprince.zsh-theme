
local user='%{$terminfo[bold]$FG[010]%}%n@%m%{$reset_color%}'
local pwd='%{$terminfo[bold]$FG[069]%}%~%{$reset_color%}'

export VIRTUAL_ENV_DISABLE_PROMPT=1

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="("
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX=")"

function virtualenv_prompt_info() {
    if [ -n "$VIRTUAL_ENV" ]; then
        if [ -f "$VIRTUAL_ENV/__name__" ]; then
            local name=`cat $VIRTUAL_ENV/__name__`
        elif [ `basename $VIRTUAL_ENV` = "__" ]; then
            local name=$(basename $(dirname $VIRTUAL_ENV))
        else
            local name=$(basename $VIRTUAL_ENV)
        fi
        echo "$ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX$name$ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX"
    fi
}


#local user='%{$terminfo[bold]$fg[green]%}%n@%m%{$reset_color%}'
#local pwd='%{$terminfo[bold]$fg[blue]%}%~%{$reset_color%}'

#local rbenv=''
#if which rbenv &> /dev/null; then
#    rbenv='%{$FG[249]%}‹%{$fg[magenta]%}$(rbenv version | sed -e "s/ (set.*$//")%{$FG[249]%}›%{$reset_color%}'
#fi

#if $VIRTUAL_ENV
    #virtualenv='%{$FG[249]%}‹%{$fg[magenta]%}$( $VIRTUAL_ENV )%{$FG[249]%}›%{$reset_color%}'
virtualenv=$VIRTUAL_ENV
#fi

local return_code='%(?..%{$fg[red]%}%? ↵%{$reset_color%})'
local git_branch='$(git_prompt_status)%{$reset_color%}$(git_prompt_info)%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[green]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY=""
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_GIT_PROMPT_ADDED="%{$terminfo[bold]$fg[green]%}✚"
ZSH_THEME_GIT_PROMPT_MODIFIED="%{$terminfo[bold]$fg[blue]%}✹"
ZSH_THEME_GIT_PROMPT_DELETED="%{$terminfo[bold]$fg[red]%}✖"
ZSH_THEME_GIT_PROMPT_RENAMED="%{$terminfo[bold]$fg[magenta]%}➜"
ZSH_THEME_GIT_PROMPT_UNMERGED="%{$terminfo[bold]$fg[yellow]%}═"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$terminfo[bold]$fg[cyan]%}✭"

PROMPT="
${user} ${pwd} $ "
#RPROMPT="${return_code} ${git_branch} ${rbenv}"
RPROMPT="${return_code} ${git_branch} ${virtualenv_promptinfo}"
