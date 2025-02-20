
if [[ $DISPLAY = '' ]] then
    alias -s md=vim
    alias -s txt=vim
else
    alias -s md=gvim
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

