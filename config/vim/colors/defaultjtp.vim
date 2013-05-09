hi clear Normal
set bg&

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif

set background=dark

let g:colors_name = "defaultjtp"

hi Comment		term=bold	   ctermfg=LightBlue   guifg=#214399

