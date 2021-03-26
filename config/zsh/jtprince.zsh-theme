
local user='%{$terminfo[bold]$FG[010]%}%n@%m%{$reset_color%}'
local pwd='%{$terminfo[bold]$FG[069]%}%~%{$reset_color%}'

export VIRTUAL_ENV_DISABLE_PROMPT=1

ZSH_THEME_VIRTUAL_ENV_PROMPT_PREFIX="‹"
ZSH_THEME_VIRTUAL_ENV_PROMPT_SUFFIX="›"

function virtualenv_prompt_info() {
    if [ -n "$VIRTUAL_ENV" ]; then
        if [ -f "$VIRTUAL_ENV/__name__" ]; then
            local name=`cat $VIRTUAL_ENV/__name__`
        elif [ `basename $VIRTUAL_ENV` = "__" ]; then
            local name=$(basename $(dirname $VIRTUAL_ENV))
        else
            local name=$(basename $VIRTUAL_ENV)
        fi
        echo "$name"
    fi
}

local rbenv=''
if which rbenv &> /dev/null; then
    rbenv='%{$FG[249]%}‹%{$fg[magenta]%}$(rbenv version | sed -e "s/ (set.*$//")%{$FG[249]%}›%{$reset_color%}'
fi

# run `spectrum_ls` to see available colors
local return_code='%(?..%{$fg[red]%}%? ↵%{$reset_color%})'
local git_branch='$(git_prompt_status)%{$reset_color%}$(git_prompt_info)%{$reset_color%}'
local virtualenv_prompt='%{$FG[249]%}‹%{$FG[044]%}$(virtualenv_prompt_info)%{$FG[249]%}›%{$reset_color%}'

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

ZSH_THEME_KUBECTX_PROD_PREFIX="%{$fg_bold[red]%}"
ZSH_THEME_KUBECTX_PROD_SUFFIX="%{$reset_color%}"
ZSH_THEME_KUBECTX_NOT_PROD_PREFIX="%{$fg[blue]%}"
ZSH_THEME_KUBECTX_NOT_PROD_SUFFIX="%{$reset_color%}"

function kubectl_context_display() {
    "${ZSH_KUBECTL_DISPLAY:=true}"
    if [ "$ZSH_KUBECTL_DISPLAY" = true ]; then
        kubectl_context=`kubectx -c`
        if [[ $kubectl_context =~ "prod" ]]; then
            echo " ${ZSH_THEME_KUBECTX_PROD_PREFIX}>>>${kubectl_context}>>>${ZSH_THEME_KUBECTX_PROD_SUFFIX} "
        else
            echo " ${ZSH_THEME_KUBECTX_NOT_PROD_PREFIX}⎈${kubectl_context}${ZSH_THEME_KUBECTX_NOT_PROD_SUFFIX} "
        fi
    else
        echo " "
    fi
}

# because we have prompt_subst set, then we want a string that will be
# substituted at display time. escape those vars
PROMPT="
${user} ${pwd}\$(kubectl_context_display)$ "

#RPROMPT="${return_code} ${git_branch} ${rbenv}"
RPROMPT="${return_code} ${git_branch} ${virtualenv_prompt}"
