
" this is meant to be for all c/cpp/h files (not sure how to make that happen)

:setlocal
set smartindent " like autoindent but recognizes some C syntax
set cindent     " clever C indenting  (or cin)
set cinkeys=0{,0},0),:,!^F,o,O,e    " this is default except for '0#'

