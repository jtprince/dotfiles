" modified to transparent background by JTP
"
" Vim color file
" Maintainer:	Thorsten Maerz <info@netztorte.de>
" Last Change:	2001 Jul 23
" grey on black
" optimized for TFT panels
" $Revision: 1.1 $

set background=dark
hi clear
if exists("syntax_on")
    syntax reset
endif
colorscheme default
let g:colors_name = "tortejtp"

" hardcoded colors :
" GUI Comment : #80a0ff = Light blue

" GUI
highlight Normal     guifg=Grey80	guibg=NONE
highlight Search     guifg=Black	guibg=Red	gui=bold
highlight Visual     guifg=Grey25			gui=bold
highlight Cursor     guifg=Black	guibg=Green	gui=bold
highlight Special    guifg=Orange
highlight Comment    guifg=#80a0ff
highlight StatusLine guifg=blue		guibg=white
highlight Statement  guifg=Yellow			gui=NONE
highlight Type						gui=NONE

" Console
highlight Normal     ctermfg=LightGrey	ctermbg=NONE
highlight Search     ctermfg=Black	ctermbg=Red	cterm=NONE
highlight Visual					cterm=reverse
highlight Cursor     ctermfg=Black	ctermbg=Green	cterm=bold
highlight Special    ctermfg=Brown
highlight Comment    ctermfg=Blue
highlight StatusLine ctermfg=blue	ctermbg=white
highlight Statement  ctermfg=Yellow			cterm=NONE
highlight Type						cterm=NONE

