" modified by John Prince from original by Thorsten Maerz
" Console color scheme for dark, transparent terminal

set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif
colorscheme default
let g:colors_name = "tortejtp"

" Console
highlight Normal     ctermfg=LightGrey  ctermbg=NONE
highlight Search     ctermfg=Black      ctermbg=Red     cterm=NONE
highlight Visual                        cterm=reverse
highlight Cursor     ctermfg=Black      ctermbg=Green   cterm=bold
highlight Special    ctermfg=Brown
highlight Comment    ctermfg=105
highlight StatusLine ctermfg=blue       ctermbg=white
highlight Statement  ctermfg=Yellow     cterm=NONE
highlight Type                          cterm=NONE

